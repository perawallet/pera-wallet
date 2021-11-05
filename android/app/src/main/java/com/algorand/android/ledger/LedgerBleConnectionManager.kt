/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ledger

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.util.Log
import com.algorand.android.BuildConfig
import com.algorand.android.R
import com.algorand.android.utils.getAccountIndexAsByteArray
import com.algorand.android.utils.getPublicKey
import com.algorand.android.utils.removeExcessBytes
import com.algorand.android.utils.shiftOneByteLeft
import java.io.ByteArrayOutputStream
import java.util.UUID
import no.nordicsemi.android.ble.BleManager
import no.nordicsemi.android.ble.callback.DataReceivedCallback
import no.nordicsemi.android.ble.data.Data

// Use with dagger.
class LedgerBleConnectionManager(appContext: Context) : BleManager<LedgerBleConnectionManagerCallback>(appContext) {

    private var characteristicWrite: BluetoothGattCharacteristic? = null
    private var characteristicNotify: BluetoothGattCharacteristic? = null

    override fun getGattCallback(): BleManagerGattCallback {
        return object : BleManagerGattCallback() {
            override fun isRequiredServiceSupported(gatt: BluetoothGatt): Boolean {
                gatt.getService(SERVICE_UUID)?.run {
                    characteristicWrite = getCharacteristic(WRITE_CHARACTERISTIC_UUID)
                    characteristicNotify = getCharacteristic(NOTIFY_CHARACTERISTIC_UUID)
                }
                return characteristicWrite != null && characteristicNotify != null
            }

            override fun onDeviceDisconnected() {
                characteristicWrite = null
                characteristicNotify = null
            }

            override fun initialize() {
                beginAtomicRequestQueue()
                    .add(requestMtu(DEFAULT_MTU)
                        .with { _, mtu -> log(Log.INFO, "MTU set to $mtu") }
                        .fail { _, status -> log(Log.WARN, "Requested MTU not supported: $status") })
                    .add(enableNotifications(characteristicNotify))
                    .done { log(Log.INFO, "Target initialized") }
                    .enqueue()
                setNotificationCallback(characteristicNotify)
                    .with(object : ReceivedDataHandler() {})
            }
        }
    }

    override fun log(priority: Int, message: String) {
        super.log(priority, message)
        if (BuildConfig.DEBUG) {
            Log.println(priority, TAG, message)
        }
    }

    abstract inner class ReceivedDataHandler : DataReceivedCallback {
        private var currentSequence = 0
        private var remainingBytes = 0
        private var actionBytesOutputStream = ByteArrayOutputStream()

        override fun onDataReceived(device: BluetoothDevice, data: Data) {
            var offset = 0
            when (data.getByte(offset++)) {
                LEDGER_CLA -> {
                    val mtuValue = data.getByte(MTU_OFFSET)
                    if (mtuValue != null) {
                        overrideMtu(mtuValue.toInt())
                    }
                }
                DATA_CLA -> {
                    val movedSequence = data.getByte(offset++)?.removeExcessBytes()?.shiftOneByteLeft()
                    val sequence = data.getByte(offset++)?.removeExcessBytes()
                    val dataCurrentSequence = sequence?.let { movedSequence?.plus(it) }

                    if (dataCurrentSequence != currentSequence) {
                        resetReceiver("Resetted Receiver $sequence")
                        return
                    }

                    if (currentSequence == 0) {
                        if (data.size() - offset < 2) {
                            resetReceiver("size is lesser than expected.")
                            return
                        }

                        val movedMsgSize = (data.getByte(offset++)!!.removeExcessBytes()).shiftOneByteLeft()
                        val msgSize = data.getByte(offset++)!!.removeExcessBytes()
                        remainingBytes = msgSize + movedMsgSize
                    }

                    val bytesToCopy = data.value?.size?.minus(offset) ?: 0

                    remainingBytes -= bytesToCopy

                    if (bytesToCopy == 0) {
                        resetReceiver("bytes to copy can't be 0.")
                        disconnect().done {
                            mCallbacks.onMissingBytes()
                        }.enqueue()
                        return
                    }

                    actionBytesOutputStream.write(data.value, offset, bytesToCopy)

                    when {
                        remainingBytes == 0 -> {
                            handleSuccessfulData(bluetoothDevice, actionBytesOutputStream.toByteArray())
                        }
                        remainingBytes > 0 -> {
                            // wait for the next message
                            currentSequence += 1
                        }
                        remainingBytes < 0 -> {
                            resetReceiver("Minus byte is remaining. Something is wrong. $remainingBytes")
                        }
                    }
                }
            }
        }

        private fun resetReceiver(message: String) {
            currentSequence = 0
            remainingBytes = 0
            actionBytesOutputStream = ByteArrayOutputStream()
            log(Log.INFO, message)
        }

        private fun handleSuccessfulData(ledgerDevice: BluetoothDevice?, data: ByteArray) {
            resetReceiver("Successfully read all.")
            if (ledgerDevice == null) {
                return
            }
            when {
                data.size == ERROR_DATA_SIZE -> {
                    when {
                        data.contentEquals(OPERATION_CANCELLED_CODE) -> mCallbacks.onOperationCancelled()
                        data.contentEquals(NEXT_PAGE_CODE) -> return
                        else -> {
                            disconnect().enqueue()
                            mCallbacks.onManagerError(
                                R.string.error_app_closed_message, R.string.error_app_closed_title
                            )
                        }
                    }
                }
                data.size == PUBLIC_KEY_RESPONSE_DATA_SIZE -> {
                    val accountPublicKey = getPublicKey(data.dropLast(RETURN_CODE_BYTE_COUNT).toByteArray())
                    if (!accountPublicKey.isNullOrEmpty()) {
                        mCallbacks.onPublicKeyReceived(ledgerDevice, accountPublicKey)
                    }
                }
                data.size > PUBLIC_KEY_RESPONSE_DATA_SIZE -> {
                    val signature = data.dropLast(RETURN_CODE_BYTE_COUNT).toByteArray()
                    mCallbacks.onTransactionSignatureReceived(ledgerDevice, signature)
                }
                else -> {
                    disconnect().enqueue()
                    mCallbacks.onManagerError(R.string.unknown_error)
                }
            }
        }
    }

    fun sendPublicKeyRequest(index: Int) {
        val atomicRequest = beginAtomicRequestQueue()
        val publicKeyRequestInstruction = PUBLIC_KEY_WITH_INDEX + getAccountIndexAsByteArray(index)
        packetizeData(publicKeyRequestInstruction).forEach { packet ->
            atomicRequest.add(writeCharacteristic(characteristicWrite, packet))
        }
        atomicRequest.enqueue()
    }

    fun sendVerifyPublicKeyRequest(index: Int) {
        val atomicRequest = beginAtomicRequestQueue()
        val verifyPublicKeyRequestInstruction = VERIFY_PUBLIC_KEY_WITH_INDEX + getAccountIndexAsByteArray(index)
        packetizeData(verifyPublicKeyRequestInstruction).forEach { packet ->
            atomicRequest.add(writeCharacteristic(characteristicWrite, packet))
        }
        atomicRequest.enqueue()
    }

    fun connectToDevice(bluetoothDevice: BluetoothDevice) {
        connect(bluetoothDevice)
            .timeout(CONNECTION_TIMEOUT)
            .retry(RETRY_COUNT, RETRY_DELAY)
            .fail { _, _ ->
                mCallbacks.onManagerError(R.string.error_connection_message, R.string.error_connection_title)
            }
            .enqueue()
    }

    fun sendSignTransactionRequest(transactionData: ByteArray, accountIndex: Int) {
        val output = mutableListOf<ByteArray>()
        var bytesRemaining = transactionData.size + ACCOUNT_INDEX_DATA_SIZE
        var offset = 0
        var p1 = P1_FIRST_WITH_ACCOUNT
        var p2 = P2_MORE

        while (bytesRemaining > 0) {
            val bytesRemainingWithHeader = bytesRemaining + HEADER_SIZE

            val packetSize: Int = if (bytesRemainingWithHeader <= CHUNK_SIZE) bytesRemainingWithHeader else CHUNK_SIZE

            val packet = ByteArrayOutputStream()

            val remainingSpaceInPacket = packetSize - HEADER_SIZE

            var bytesToCopyLength =
                if (remainingSpaceInPacket < bytesRemaining) remainingSpaceInPacket else bytesRemaining

            bytesRemaining -= bytesToCopyLength

            if (bytesRemaining == 0) {
                p2 = P2_LAST
            }

            with(packet) {
                write(ALGORAND_CLA)
                write(SIGN_INS)
                write(p1)
                write(p2)
                write(bytesToCopyLength)
                if (p1 == P1_FIRST_WITH_ACCOUNT) {
                    write(getAccountIndexAsByteArray(accountIndex))
                    bytesToCopyLength -= ACCOUNT_INDEX_DATA_SIZE
                }
                write(transactionData, offset, bytesToCopyLength)
                offset += bytesToCopyLength
            }

            p1 = P1_MORE

            output.add(packet.toByteArray())
            log(Log.INFO, packet.toByteArray().toString())
        }

        if (output.isNotEmpty()) {
            val atomicRequest = beginAtomicRequestQueue()
            output.forEach { chunkData ->
                packetizeData(chunkData).forEach { packet ->
                    atomicRequest.add(writeCharacteristic(characteristicWrite, packet))
                }
            }
            atomicRequest.enqueue()
        } else {
            log(Log.INFO, "No data is found on the array.")
        }
    }

    // Every data must be sent as packetized.
    private fun packetizeData(msg: ByteArray): List<ByteArray> {
        val out = mutableListOf<ByteArray>()
        var sequenceIdx = 0
        var offset = 0
        var first = true
        var remainingBytes = msg.size

        while (remainingBytes > 0) {
            val byteArrayOutputStream = ByteArrayOutputStream()

            // 0x05 Marks application specific data
            byteArrayOutputStream.write(DATA_CLA.toInt())

            // Encode sequence number
            byteArrayOutputStream.write(sequenceIdx.shiftOneByteLeft())
            byteArrayOutputStream.write(sequenceIdx.removeExcessBytes())

            // If this is the first packet, also encode the total message length
            if (first) {
                byteArrayOutputStream.write(msg.size.shiftOneByteLeft())
                byteArrayOutputStream.write(msg.size.removeExcessBytes())
                first = false
            }

            // Copy some number of bytes into the packet
            val remainingSpaceInPacket = mtu - byteArrayOutputStream.size() - CONSTANT_BYTE_COUNT
            val bytesToCopy = if (remainingSpaceInPacket < remainingBytes) {
                remainingSpaceInPacket
            } else {
                remainingBytes
            }

            remainingBytes -= bytesToCopy

            byteArrayOutputStream.write(msg, offset, bytesToCopy)

            sequenceIdx += 1
            offset += bytesToCopy

            out.add(byteArrayOutputStream.toByteArray())
        }
        return out
    }

    fun isTryingToConnect(): Boolean {
        return (connectionState == BluetoothProfile.STATE_DISCONNECTED ||
            connectionState == BluetoothProfile.STATE_DISCONNECTING).not()
    }

    fun isDeviceConnected(deviceAddress: String): Boolean {
        return bluetoothDevice?.address == deviceAddress && isTryingToConnect()
    }

    companion object {
        private const val SERVICE_KEY = "13D63400-2C97-0004-0000-4C6564676572"
        private const val WRITE_CHARACTERISTIC_KEY = "13D63400-2C97-0004-0002-4C6564676572"
        private const val NOTIFIY_CHARACTERISCTIC_KEY = "13D63400-2C97-0004-0001-4C6564676572"

        val SERVICE_UUID = UUID.fromString(SERVICE_KEY)

        private const val DEFAULT_MTU = 23
        private const val CONNECTION_TIMEOUT = 18000L
        private const val RETRY_COUNT = 0
        private const val RETRY_DELAY = 300

        private const val RETURN_CODE_BYTE_COUNT = 2

        private const val MTU_OFFSET = 5

        private const val LEDGER_CLA: Byte = 0x08
        private const val DATA_CLA: Byte = 0x05

        private const val ALGORAND_CLA = 0x80
        private const val PUBLIC_KEY_INS = 0x03
        private const val SIGN_INS = 0x08

        private const val P1_FIRST_WITH_ACCOUNT = 0x01
        private const val P1_FIRST = 0x00
        private const val P1_MORE = 0x80
        private const val P2_LAST = 0x00
        private const val P2_MORE = 0x80

        const val ACCOUNT_INDEX_DATA_SIZE = 0x04

        // this need one more byte which is index of the account.
        // toByte is evaluated at compile time so, it's ok this way.
        private val PUBLIC_KEY_WITH_INDEX = byteArrayOf(
            ALGORAND_CLA.toByte(),
            PUBLIC_KEY_INS.toByte(),
            P1_FIRST.toByte(),
            P2_LAST.toByte(),
            ACCOUNT_INDEX_DATA_SIZE.toByte(),
        )

        private val VERIFY_PUBLIC_KEY_WITH_INDEX = byteArrayOf(
            ALGORAND_CLA.toByte(),
            PUBLIC_KEY_INS.toByte(),
            P1_MORE.toByte(),
            P2_LAST.toByte(),
            ACCOUNT_INDEX_DATA_SIZE.toByte()
        )

        private const val CHUNK_SIZE = 0xFF
        private const val HEADER_SIZE = 5

        private const val CONSTANT_BYTE_COUNT = 3

        private val WRITE_CHARACTERISTIC_UUID = UUID.fromString(WRITE_CHARACTERISTIC_KEY)
        private val NOTIFY_CHARACTERISTIC_UUID = UUID.fromString(NOTIFIY_CHARACTERISCTIC_KEY)

        private const val PUBLIC_KEY_RESPONSE_DATA_SIZE = 34
        private const val ERROR_DATA_SIZE = 2

        private val OPERATION_CANCELLED_CODE = byteArrayOf(0x69, 0x85.toByte())
        private val NEXT_PAGE_CODE = byteArrayOf(0x90.toByte(), 0x00.toByte())

        private const val TAG = "LedgerBleManager"
    }
}

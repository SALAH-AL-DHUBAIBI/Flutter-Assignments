package com.example.smart_call_sms_manager

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.app.NotificationManager
import android.app.NotificationChannel
import android.os.Build
import androidx.core.app.NotificationCompat

class SmsReceiver : BroadcastReceiver() {
    
    companion object {
        // Store message parts temporarily to combine multi-part SMS
        private val messageBuffer = mutableMapOf<String, StringBuilder>()
        private val messageTimestamps = mutableMapOf<String, Long>()
        private const val MESSAGE_TIMEOUT = 5000L // 5 seconds
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            // Group messages by sender
            val messagesBySender = messages.groupBy { it.displayOriginatingAddress }
            
            for ((sender, smsMessages) in messagesBySender) {
                // Combine all message parts
                val fullMessage = smsMessages.joinToString("") { it.messageBody ?: "" }
                
                // Clean up old buffered messages
                cleanupOldMessages()
                
                // Buffer the message to handle multi-part SMS
                val currentTime = System.currentTimeMillis()
                val bufferedMessage = messageBuffer.getOrPut(sender) { StringBuilder() }
                bufferedMessage.append(fullMessage)
                messageTimestamps[sender] = currentTime
                
                // Show notification with the complete message
                showNotification(context, sender, bufferedMessage.toString())
                
                // Clear buffer for this sender after showing notification
                messageBuffer.remove(sender)
                messageTimestamps.remove(sender)
            }
        }
    }
    
    private fun cleanupOldMessages() {
        val currentTime = System.currentTimeMillis()
        val toRemove = messageTimestamps.filter { 
            currentTime - it.value > MESSAGE_TIMEOUT 
        }.keys
        
        toRemove.forEach { sender ->
            messageBuffer.remove(sender)
            messageTimestamps.remove(sender)
        }
    }
    
    private fun showNotification(context: Context, sender: String, message: String) {
        val channelId = "sms_notifications"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create notification channel for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "SMS Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for incoming SMS messages"
            }
            notificationManager.createNotificationChannel(channel)
        }
        
        // Use sender address as notification ID to replace previous notifications from same sender
        val notificationId = sender.hashCode()
        
        // Build notification with BigTextStyle for expandable long messages
        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentTitle("New message from $sender")
            .setContentText(message)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(message)
                    .setBigContentTitle("New message from $sender")
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setOnlyAlertOnce(false) // Alert for each new message
            .build()
        
        notificationManager.notify(notificationId, notification)
    }
}

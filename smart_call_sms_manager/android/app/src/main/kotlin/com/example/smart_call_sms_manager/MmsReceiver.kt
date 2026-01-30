package com.example.smart_call_sms_manager

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // We do not handle MMS in this basic version, but the receiver is required for Default App component.
    }
}

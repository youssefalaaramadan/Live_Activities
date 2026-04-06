package com.example.live_activities_usecase

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import com.example.live_activities.LiveActivityManager

class CustomLiveActivityManager(context: Context) :
    LiveActivityManager(context) {

    private val appContext = context.applicationContext

    private val pendingIntent = PendingIntent.getActivity(
        appContext,
        200,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    private val remoteViews = RemoteViews(
        appContext.packageName,
        R.layout.live_activity
    )

    // ✅ Load image safely
    private suspend fun loadImageBitmap(imageUrl: String?): Bitmap? {
        if (imageUrl.isNullOrEmpty()) return null

        return withContext(Dispatchers.IO) {
            try {
                val connection = URL(imageUrl).openConnection() as HttpURLConnection
                connection.connectTimeout = 3000
                connection.readTimeout = 3000
                connection.doInput = true
                connection.connect()

                connection.inputStream.use { input ->
                    val original = BitmapFactory.decodeStream(input)

                    val density = appContext.resources.displayMetrics.density
                    val targetSize = (64 * density).toInt()

                    original?.let {
                        Bitmap.createScaledBitmap(it, targetSize, targetSize, true)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
    }

    // ✅ Main UI updater
    private suspend fun updateRemoteViews(
        data: Map<String, Any>,
        isUpdate: Boolean
    ) {
        val team1Name = data["teamAName"] as? String ?: "Team A"
        val team2Name = data["teamBName"] as? String ?: "Team B"

        val team1Score = (data["teamAScore"] as? Number)?.toInt() ?: 0
        val team2Score = (data["teamBScore"] as? Number)?.toInt() ?: 0

        val timestamp = (data["matchStartDate"] as? Number)?.toLong()
            ?: System.currentTimeMillis()

        remoteViews.setTextViewText(R.id.team1_name, team1Name)
        remoteViews.setTextViewText(R.id.team2_name, team2Name)
        remoteViews.setTextViewText(R.id.score, "$team1Score : $team2Score")

        // ✅ Chronometer (correct)
        val elapsed = android.os.SystemClock.elapsedRealtime()
        val base = elapsed - (System.currentTimeMillis() - timestamp)

        remoteViews.setChronometer(R.id.match_time, base, null, true)

        // ✅ Click handling
        remoteViews.setOnClickPendingIntent(R.id.root_layout, pendingIntent)

        // ✅ Load images ONLY on create
        if (!isUpdate) {
            val team1Url = data["teamAImageUrl"] as? String
            val team2Url = data["teamBImageUrl"] as? String

            loadImageBitmap(team1Url)?.let {
                remoteViews.setImageViewBitmap(R.id.team1_image_placeholder, it)
            }

            loadImageBitmap(team2Url)?.let {
                remoteViews.setImageViewBitmap(R.id.team2_image_placeholder, it)
            }
        }
    }

    // ✅ MAIN ENTRY POINT
    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {

        val isUpdate = event == "update"

        updateRemoteViews(data, isUpdate)

        return notification
            .setSmallIcon(R.drawable.ic_notification)
            .setOngoing(true)
            .setContentTitle(data["matchName"] as? String ?: "Live Match")
            .setContentIntent(pendingIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setPriority(Notification.PRIORITY_LOW)
            .setCategory(Notification.CATEGORY_EVENT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}
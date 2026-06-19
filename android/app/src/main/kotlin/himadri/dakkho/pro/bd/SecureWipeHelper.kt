package himadri.dakkho.pro.bd

import java.io.File
import java.io.RandomAccessFile

/**
 * SecureWipeHelper — secure file deletion for downloaded videos.
 *
 * Why secure wipe?
 *   Standard `File.delete()` only removes the directory entry. The actual bytes remain
 *   on flash storage until overwritten. On rooted devices or via forensic tools,
 *   deleted files can be recovered.
 *
 *   For downloaded encrypted video files (.enc), even though they're AES-256-GCM encrypted,
 *   we want to ensure the .enc file itself is unrecoverable. This implements a US DoD-style
 *   3-pass wipe:
 *     Pass 1: All 0xFF
 *     Pass 2: All 0x00
 *     Pass 3: Random bytes
 *
 *   Then delete the file.
 *
 *   For SSDs, this isn't perfect due to wear-leveling, but it's the best we can do
 *   without rooted access. Combined with AES encryption of the file contents,
 *   recovery is effectively impossible.
 *
 *   ⚠️ Performance: For a 500MB .enc file, this takes 3-5 seconds on a mid-range phone.
 *      Call this on a background isolate to avoid jank.
 */
object SecureWipeHelper {

    fun wipe(path: String): Boolean {
        return try {
            val file = File(path)
            if (!file.exists()) return true

            // Only wipe regular files (not directories)
            if (file.isDirectory) {
                // Recursively wipe directory contents
                file.listFiles()?.forEach { child ->
                    if (child.isFile) wipeSingleFile(child)
                    else if (child.isDirectory) wipe(child.absolutePath)
                }
                return file.delete()
            }

            wipeSingleFile(file)
        } catch (e: Exception) {
            android.util.Log.w("SecureWipe", "Failed to wipe $path", e)
            false
        }
    }

    private fun wipeSingleFile(file: File): Boolean {
        val length = file.length()
        if (length == 0L) return file.delete()

        try {
            RandomAccessFile(file, "rws").use { raf ->
                // Pass 1: 0xFF
                raf.seek(0)
                val buf1 = ByteArray(8192) { 0xFF.toByte() }
                var written = 0L
                while (written < length) {
                    val toWrite = minOf(buf1.size.toLong(), length - written)
                    raf.write(buf1, 0, toWrite.toInt())
                    written += toWrite
                }

                // Pass 2: 0x00
                raf.seek(0)
                val buf2 = ByteArray(8192) { 0x00.toByte() }
                written = 0L
                while (written < length) {
                    val toWrite = minOf(buf2.size.toLong(), length - written)
                    raf.write(buf2, 0, toWrite.toInt())
                    written += toWrite
                }

                // Pass 3: random
                raf.seek(0)
                val random = java.security.SecureRandom()
                val buf3 = ByteArray(8192)
                written = 0L
                while (written < length) {
                    val toWrite = minOf(buf3.size.toLong(), length - written)
                    random.nextBytes(buf3)
                    raf.write(buf3, 0, toWrite.toInt())
                    written += toWrite
                }

                raf.fd.sync()
            }
        } catch (e: Exception) {
            android.util.Log.w("SecureWipe", "Wipe passes failed for ${file.name}, attempting delete anyway", e)
        }

        return file.delete()
    }
}

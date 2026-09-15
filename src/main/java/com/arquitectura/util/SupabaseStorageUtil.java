package com.arquitectura.util;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.UUID;

public class SupabaseStorageUtil {

    // URL base de Supabase (sin /rest/v1/)
    private static final String SUPABASE_URL = "https://nosmllupbhkcvxcizkkz.supabase.co";
    private static final String SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vc21sbHVwYmhrY3Z4Y2l6a2t6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk0ODI5NzMsImV4cCI6MjEwNTA1ODk3M30.GpO3-tkCOAKr6CbOIgY0SzXM01TvYh8tFb5cYSaB440";

    /**
     * Sube un archivo mediante HTTP POST a Supabase Storage API REST y retorna su URL pública.
     */
    public static String uploadFile(String bucketName, String originalFilename, InputStream inputStream, String contentType) throws Exception {
        String ext = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString() + ext;

        // Endpoint correcto de Supabase Storage: https://PROJECT.supabase.co/storage/v1/object/BUCKET/FILENAME
        String uploadEndpoint = SUPABASE_URL + "/storage/v1/object/" + bucketName + "/" + fileName;

        URL url = new URL(uploadEndpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Bearer " + SUPABASE_KEY);
        conn.setRequestProperty("apikey", SUPABASE_KEY);
        conn.setRequestProperty("Content-Type", (contentType != null && !contentType.isEmpty()) ? contentType : "application/octet-stream");

        try (OutputStream os = conn.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == 200 || responseCode == 201) {
            // Devuelve la URL pública del archivo en Supabase Storage
            return SUPABASE_URL + "/storage/v1/object/public/" + bucketName + "/" + fileName;
        } else {
            throw new RuntimeException("Error al subir archivo a Supabase Storage. HTTP Code: " + responseCode);
        }
    }
}

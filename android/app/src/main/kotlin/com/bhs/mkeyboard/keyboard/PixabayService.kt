package com.bhs.mkeyboard.keyboard

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.android.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/**
 * Pixabay API service for fetching keyboard wallpapers
 */
object PixabayService {
    
    // TODO: Replace with your Pixabay API key from https://pixabay.com/api/docs/
    private const val API_KEY = "7728716-2d9054381871f3f39700f8c1c"
    private const val BASE_URL = "https://pixabay.com/api/"
    
    private val client = HttpClient(Android) {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
            })
        }
    }
    
    /**
     * Wallpaper categories for quick selection
     */
    val categories = listOf(
        WallpaperCategory("Nature", "nature landscape"),
        WallpaperCategory("Abstract", "abstract pattern"),
        WallpaperCategory("City", "city night skyline"),
        WallpaperCategory("Space", "galaxy stars universe"),
        WallpaperCategory("Minimal", "minimal simple gradient"),
        WallpaperCategory("Dark", "dark black texture"),
        WallpaperCategory("Colorful", "colorful vibrant"),
        WallpaperCategory("Patterns", "geometric pattern texture"),
        WallpaperCategory("Tribal", "tribal ethnic pattern"),
        WallpaperCategory("Indian", "india traditional art")
    )
    
    /**
     * Fetch wallpapers by category/search query
     */
    suspend fun searchWallpapers(query: String, perPage: Int = 20): Result<List<PixabayImage>> {
        return try {
            val response: PixabayResponse = client.get(BASE_URL) {
                parameter("key", API_KEY)
                parameter("q", query)
                parameter("image_type", "photo")
                parameter("orientation", "horizontal")
                parameter("min_width", 800)
                parameter("per_page", perPage)
                parameter("safesearch", "true")
            }.body()
            
            Result.success(response.hits)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Get popular wallpapers (editors' choice)
     */
    suspend fun getPopularWallpapers(perPage: Int = 20): Result<List<PixabayImage>> {
        return try {
            val response: PixabayResponse = client.get(BASE_URL) {
                parameter("key", API_KEY)
                parameter("image_type", "photo")
                parameter("orientation", "horizontal")
                parameter("min_width", 800)
                parameter("per_page", perPage)
                parameter("safesearch", "true")
                parameter("editors_choice", "true")
            }.body()
            
            Result.success(response.hits)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

@Serializable
data class PixabayResponse(
    val total: Int,
    val totalHits: Int,
    val hits: List<PixabayImage>
)

@Serializable
data class PixabayImage(
    val id: Int,
    val previewURL: String,
    val webformatURL: String,     // Medium resolution (640px width)
    val largeImageURL: String,    // Large resolution (1280px width)
    val imageWidth: Int,
    val imageHeight: Int,
    val tags: String
)

data class WallpaperCategory(
    val name: String,
    val query: String
)

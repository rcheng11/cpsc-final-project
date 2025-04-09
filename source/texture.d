/*
Adapted from file of same name from PSET 6
(Yale CPSC 409, Prof. Mike Shah) 
*/
/// Module to handle texture loading
module texture;

import bindbc.opengl;
import bindbc.sdl;
import std.string;

/// Abstraction for generating an OpenGL texture on GPU memory from an image filename.
class Texture{
		GLuint mTextureID;
		/// Create a new texture
		this(string filename){

                SDL_Surface* surface = IMG_Load(filename.toStringz);
                assert(surface != null, "Failed to load image: " ~ filename);

                // convert surface data to img_data
                SDL_Surface* converted = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA32, 0);
                SDL_FreeSurface(surface);
                assert(converted !is null, "Failed to convert surface to RGBA32");

                int width = converted.w;
                int height = converted.h;
                
				glGenTextures(1,&mTextureID);
				glBindTexture(GL_TEXTURE_2D, mTextureID);

				glTexImage2D(
								GL_TEXTURE_2D, 	 // 2D Texture
								0,							 // mimap level 0
								GL_RGBA, 				 // Internal format for OpenGL
								width,					 // width of incoming data
								height,					 // height of incoming data
								0,							 // border (must be 0)
								GL_RGBA,					 // image format
								GL_UNSIGNED_BYTE,// image data 
								cast(void*)converted.pixels); // pixel array on CPU data

				glGenerateMipmap(GL_TEXTURE_2D);

				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_REPEAT);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_REPEAT);	

//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	
		}

}
/*
Adapted from file of same name from PSET 6
(Yale CPSC 409, Prof. Mike Shah) 
*/
/// Module to handle texture loading
module texture;

import std.string;
import std.stdio;

import bindbc.opengl;
import bindbc.sdl;


/// Abstraction for generating an OpenGL texture on GPU memory from an image filename.
class Texture{
		GLuint mTextureID;
		int mWidth;
		int mHeight;
		/// Create a new texture
		this(string filename){
                writeln("Loading texture from: "~filename);
                SDL_Surface* surface = IMG_Load(filename.toStringz);
                assert(surface != null, "Failed to load image: " ~ filename);

                // convert surface data to img_data
                SDL_Surface* converted = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA32, 0);
                SDL_FreeSurface(surface);
                assert(converted !is null, "Failed to convert surface to RGBA32");
                writeln("Successfully converted to surface...");

                int width = converted.w;
                int height = converted.h;

				mWidth = width;
				mHeight = height;
                
                writeln("Generating texture...");
				glGenTextures(1,&mTextureID);
				glBindTexture(GL_TEXTURE_2D, mTextureID);

                writeln("Converting to OpenGL texture...");
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
                writeln("Successfully converted "~filename~" to OpenGL Texture");	

//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
//				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	
		}
		/// Allocate memory for a texture with either color or depth 
		this(int width, int height, bool bColor=true){
				if(bColor){
					CreateTextureRGB(width, height);	
				}else{
					CreateTextureDepth(width,height);
				}
		}
		/// Creates an empty texture that can be populated with pixel data
		/// later on.
		/// Also useful if you will write to the texture in a framebuffer
		/// for instance.
		GLuint CreateTextureDepth(int width, int height){
				glGenTextures(1,&mTextureID);
				glBindTexture(GL_TEXTURE_2D, mTextureID);

				glTexImage2D(
								GL_TEXTURE_2D, 	 // 2D Texture
								0,							 // mimap level 0
								GL_DEPTH_COMPONENT, 				 // Internal format for OpenGL
								width,					 // width of incoming data
								height,					 // height of incoming data
								0,							 // border (must be 0)
								GL_DEPTH_COMPONENT,					 // image format
								GL_UNSIGNED_BYTE,// image data 
								null); // pixel array on CPU data

				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	

				return mTextureID;
		}

		/// Creates an empty texture that can be populated with pixel data
		/// later on.
		/// Also useful if you will write to the texture in a framebuffer
		/// for instance.
		GLuint CreateTextureRGB(int width, int height){
				glGenTextures(1,&mTextureID);
				glBindTexture(GL_TEXTURE_2D, mTextureID);

				glTexImage2D(
								GL_TEXTURE_2D, 	 // 2D Texture
								0,							 // mimap level 0
								GL_RGB, 				 // Internal format for OpenGL
								width,					 // width of incoming data
								height,					 // height of incoming data
								0,							 // border (must be 0)
								GL_RGB,					 // image format
								GL_UNSIGNED_BYTE,// image data 
								null); // pixel array on CPU data

				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	

				return mTextureID;
		}

		GLuint GetTextureID() const {
			return mTextureID;
		}


}
// /// Module to handle texture loading
// module texture;

// import image;

// import bindbc.opengl;

// /// Abstraction for generating an OpenGL texture on GPU memory from an image filename.
// class Texture{
// 		GLuint mTextureID;

// 		/// Create a new texture that stores RGB values
// 		this(string filename){
// 				CreateTextureRGBFromImage(filename);
// 		}
// 		/// Allocate memory for a texture with either color or depth 
// 		this(int width, int height, bool bColor=true){
// 				if(bColor){
// 					CreateTextureRGB(width, height);	
// 				}else{
// 					CreateTextureDepth(width,height);
// 				}
// 		}

// 		GLuint GetTextureID() const {
// 			return mTextureID;
// 		}

// 		/// Creates an empty texture that can be populated with pixel data
// 		/// later on.
// 		/// Also useful if you will write to the texture in a framebuffer
// 		/// for instance.
// 		GLuint CreateTextureDepth(int width, int height){
// 				glGenTextures(1,&mTextureID);
// 				glBindTexture(GL_TEXTURE_2D, mTextureID);

// 				glTexImage2D(
// 								GL_TEXTURE_2D, 	 // 2D Texture
// 								0,							 // mimap level 0
// 								GL_DEPTH_COMPONENT, 				 // Internal format for OpenGL
// 								width,					 // width of incoming data
// 								height,					 // height of incoming data
// 								0,							 // border (must be 0)
// 								GL_DEPTH_COMPONENT,					 // image format
// 								GL_UNSIGNED_BYTE,// image data 
// 								null); // pixel array on CPU data

// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	

// 				return mTextureID;
// 		}

// 		/// Creates an empty texture that can be populated with pixel data
// 		/// later on.
// 		/// Also useful if you will write to the texture in a framebuffer
// 		/// for instance.
// 		GLuint CreateTextureRGB(int width, int height){
// 				glGenTextures(1,&mTextureID);
// 				glBindTexture(GL_TEXTURE_2D, mTextureID);

// 				glTexImage2D(
// 								GL_TEXTURE_2D, 	 // 2D Texture
// 								0,							 // mimap level 0
// 								GL_RGB, 				 // Internal format for OpenGL
// 								width,					 // width of incoming data
// 								height,					 // height of incoming data
// 								0,							 // border (must be 0)
// 								GL_RGB,					 // image format
// 								GL_UNSIGNED_BYTE,// image data 
// 								null); // pixel array on CPU data

// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	

// 				return mTextureID;
// 		}

// 		/// Load a texture by filename
// 		/// TODO: Only supports .ppm -- should check file extension
// 		/// 			prior to otherwise loading.
// 		GLuint CreateTextureRGBFromImage(string filename){
//         import std.file;
//         if(!exists(filename)){
//           assert(0,"Attempt to create texture from image: '"~filename~"' failed");
//         }

// 				glGenTextures(1,&mTextureID);
// 				glBindTexture(GL_TEXTURE_2D, mTextureID);

// 				PPM ppm;
// 				ubyte[] image_data = ppm.LoadPPMImage(filename);

// 				glTexImage2D(
// 								GL_TEXTURE_2D, 	 // 2D Texture
// 								0,							 // mimap level 0
// 								GL_RGB, 				 // Internal format for OpenGL
// 								ppm.mWidth,					 // width of incoming data
// 								ppm.mHeight,					 // height of incoming data
// 								0,							 // border (must be 0)
// 								GL_RGB,					 // image format
// 								GL_UNSIGNED_BYTE,// image data 
// 								image_data.ptr); // pixel array on CPU data

// 				glGenerateMipmap(GL_TEXTURE_2D);

// //				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);	
// //				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
// //				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_REPEAT);	
// //				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_REPEAT);	

// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_BORDER);	
// 				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_BORDER);	
// 				return mTextureID;
// 		}
// }

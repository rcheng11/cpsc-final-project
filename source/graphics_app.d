

/// The main graphics application with the main graphics loop.
module graphics_app;
import std.stdio;
import core;
import mesh, linear, scene, materials, geometry, rendertarget, graphics_window;
import utility;
import parser;
import platform;
import std.math;

import bindbc.sdl;
import bindbc.opengl;

/// The main graphics application.
struct GraphicsApp{
		bool mGameIsRunning		= true;
		bool mRenderWireframe = false;
		bool mStopRotation = false;
        bool mStopLightRotation = false;
        P3DObj mObj;
        float mShearAmt = ToRadians(-40.0);
        float mLightAngle = 0.0;

		vec3 lightPos;
		
		// Window for the graphics application
		GraphicsWindow mWindow;
		// Scene
		SceneTree mSceneTree;
		// Camera
		Camera mCamera;
		// Renderer
		Renderer mRenderer;	
		// Note: For future, you can use for post rendering effects on the renderer
    //		PostRenderDraw mPostRenderer;

		/// Setup OpenGL and any libraries
		this(int screenWidth, int screenHeight, string title, int major_ogl_version, int minor_ogl_version){
				// Create a window
				mWindow = new OpenGLWindow(title, major_ogl_version, minor_ogl_version);
				// Create a renderer
        // NOTE: For now, our renderer will draw into the default renderbuffer (so 'null' for final pamater.
				mRenderer = new Renderer(mWindow,screenWidth,screenHeight, null);
        // NOTE: In future, you can create a custom render target to draw to as follows.
				//       mRenderer = new Renderer(mWindow,640,480, new RenderTarget(640,480));
				// Handle effects for the renderer
        // mPostRenderer = new PostRenderDraw("screen","./pipelines/screen/"); 

				// Create a camera
				mCamera = new Camera();
				// Create (or load) a Scene Tree
				mSceneTree = new SceneTree("root");
		}

		/// Destructor
		~this(){

		}

		/// Handle input
		void Input(){
				// Store an SDL Event
				SDL_Event event;
				while(SDL_PollEvent(&event)){
						if(event.type == SDL_QUIT){
								writeln("Exit event triggered (probably clicked 'x' at top of the window)");
								mGameIsRunning= false;
						}
						if(event.type == SDL_KEYDOWN){
								if(event.key.keysym.scancode == SDL_SCANCODE_ESCAPE){
										writeln("Pressed escape key and now exiting...");
										mGameIsRunning= false;
								}else if(event.key.keysym.sym == SDLK_TAB){
										mRenderWireframe = !mRenderWireframe;
								}
								else if(event.key.keysym.sym == SDLK_DOWN){
										mCamera.MoveBackwardZ();
								}
								else if(event.key.keysym.sym == SDLK_UP){
										mCamera.MoveForwardZ();
								}
								else if(event.key.keysym.sym == SDLK_LEFT){
										mCamera.MoveLeft();
								}
								else if(event.key.keysym.sym == SDLK_RIGHT){
										mCamera.MoveRight();
								}
								else if(event.key.keysym.sym == SDLK_a){
										mCamera.MoveUp();
								}
								else if(event.key.keysym.sym == SDLK_z){
										mCamera.MoveDown();
								}
                                else if(event.key.keysym.sym == SDLK_i){
										// mCamera.TurnUp(1);
                                        mShearAmt += ToRadians(1);
								}
                                else if(event.key.keysym.sym == SDLK_k){
										// mCamera.TurnDown(1);
                                        mShearAmt -= ToRadians(1);
								}
                                else if(event.key.keysym.sym == SDLK_j){
										mCamera.TurnLeft(1);
								}
                                else if(event.key.keysym.sym == SDLK_l){
										mCamera.TurnRight(1);
								}
								else if(event.key.keysym.sym == SDLK_r){
									mStopRotation = !mStopRotation;
								}
                                else if(event.key.keysym.sym == SDLK_e){
									mStopLightRotation = !mStopLightRotation;
								}
								writeln("Camera Position: ",mCamera.mEyePosition);
						}
				}

				// Retrieve the mouse position
				// int mouseX,mouseY;
				// SDL_GetMouseState(&mouseX,&mouseY);
				// mCamera.MouseLook(mouseX,mouseY);

		}
        void loadModel(P3DObj obj){
            // load model (only call after OpenGL instance loaded!)
            mObj = obj;
            obj.initialize(); // loads textures
        }
		/// A helper function to setup a scene.
		/// NOTE: In the future this can use a configuration file to otherwise make our graphics applications
		///       data-driven.
		void SetupScene(){
				// Normal Map pipeline creation
				Pipeline  normalMap      = new Pipeline("normalmap","./pipelines/normalmap/");
				lightPos = vec3(0, 3.0, -1.25); // initialize light location

                foreach(slice ; mObj.getSpriteStack().getSlices()){
                    IMaterial normalMaterial = new NormalMapMaterial("normalmap",slice);
                    // Create an slice and add it to scene tree
                    ISurface obj = MakeTexturedNormalMappedQuad(slice);
                    MeshNode  m  = new MeshNode("quad",obj,normalMaterial);
                    mSceneTree.GetRootNode().AddChildSceneNode(m);
                    slice.attachMeshNode(m);

                    normalMaterial.AddUniform(new Uniform("uModel", "mat4", m.mModelMatrix.DataPtr()));
                    normalMaterial.AddUniform(new Uniform("uView", "mat4", mCamera.mViewMatrix.DataPtr()));
                    normalMaterial.AddUniform(new Uniform("uProjection", "mat4", mCamera.mProjectionMatrix.DataPtr()));
                    // set the light and view positions
                    normalMaterial.AddUniform(new Uniform("lightPos", "vec3", &lightPos));
                    normalMaterial.AddUniform(new Uniform("viewPos", "vec3", mCamera.mEyePosition.DataPtr()));
                }
		}

		/// Update gamestate
		void Update(){
				// A rotation value that 'updates' every frame to give some animation in our scene
				static float yRotation = 0.0f;
				if(!mStopRotation){
					yRotation += 0.01f;
				}

                float radius = 4.0;
                // float time = SDL_GetTicks() / 500.0f;
                if(!mStopLightRotation){
                    mLightAngle += ToRadians(1);
                    lightPos.x = sin(mLightAngle) * radius;
                    lightPos.y = 2.0;
                    lightPos.z = cos(mLightAngle) * radius - 1.25; // offset
				}

                // float radius = 3.0f;
				// float time = SDL_GetTicks() / 500.0f;
				// lightPos.x = 0;
				// lightPos.y = cos(time) * radius;
				// lightPos.z = sin(time) * radius;

				// Update our first object
				// MeshNode m = cast(MeshNode)mSceneTree.FindNode("quad");
				// Transform our mesh node
				// Note: Before most transformations, we set the 'identity' matrix, and then
				//       perform our transformations.

                foreach(slice ; mObj.getSpriteStack().getSlices()){
                    slice.mMeshNode.LoadIdentity()
                        .Translate(slice.mX, slice.mY, slice.mZ)
                        .RotateX(mShearAmt)
                        .RotateZ(yRotation);
                }
		}

		/// Render our scene by traversing the scene tree from a specific viewpoint
		void Render(){
                glEnable(GL_BLEND);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				if(mRenderWireframe){
						glPolygonMode(GL_FRONT_AND_BACK,GL_LINE); 
				}else{
						glPolygonMode(GL_FRONT_AND_BACK,GL_FILL); 
				}

				// Render the scene tree form a specific camera
				mRenderer.Render(mSceneTree, mCamera);
				// Post renderer
				//mPostRenderer.PostRender(mRenderer);
		}

		/// Process 1 frame
		void AdvanceFrame(){
				Input();
				Update();
				Render();

				SDL_Delay(16);	// NOTE: This is a simple way to cap framerate at 60 FPS,
												// 		   you might be inclined to improve things a bit.
		}

		/// Main application loop
		void Loop(){
				// Setup the graphics scene
				SetupScene();

				// Lock mouse to center of screen
				// This will help us get a continuous rotation.
				// NOTE: On occasion folks on virtual machine or WSL may not have this work,
				//       so you'll have to compute the 'diff' and reposition the mouse yourself.
				SDL_WarpMouseInWindow(mWindow.mWindow,640/2,320/2);

				// Run the graphics application loop
				while(mGameIsRunning){
						AdvanceFrame();
				}
		}
}


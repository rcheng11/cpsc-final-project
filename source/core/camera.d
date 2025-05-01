/// This represents a camera abstraction.
module camera;

import linear;
import parser;
import mat;
import scene, mesh;
import bindbc.opengl;

/// Camera abstraction.
class Camera{
    mat4 mViewMatrix;
    mat4 mProjectionMatrix;

    vec3 mEyePosition;          /// This is our 'translation' value
    // Axis of the camera
    vec3 mUpVector;             /// This is 'up' in the world
    vec3 mForwardVector;        /// This is on the camera axis
    vec3 mRightVector;          /// This is where 'right' is

    /// Constructor for a camera
    this(){
        // Setup our camera (view matrix) 
        mViewMatrix = MatrixMakeIdentity();

        // Setup our perspective projection matrix
        // NOTE: Assumption made here is our window is always 640/480 or the similar aspect ratio.
        mProjectionMatrix = MatrixMakePerspective(90.0f.ToRadians,480.0f/640.0f, 0.1f, 1000.0f);

        /// Initial Camera setup
        mEyePosition    = vec3(0.0f,1.8f,2.2f); // initial position
        // Eye position
        // Forward vector matching the positive z-axis
        mForwardVector  = vec3(0.0f, 0.0f, 1.0f);
        // Where up is in the world initially
        mUpVector       = vec3(0.0f,1.0f,0.0f);
        // Where right is initially
        mRightVector    = vec3(1.0f, 0.0f, 0.0f);

        UpdateViewMatrix();

    }

    /// Position the eye of the camera in the world
    void SetCameraPosition(vec3 v){
        UpdateViewMatrix();
        mEyePosition = v;
    }
    /// Position the eye of the camera in the world
    void SetCameraPosition(float x, float y, float z){
        UpdateViewMatrix();
        mEyePosition = vec3(x,y,z);
    }

    /// Builds a matrix for where the matrix is looking
    /// given the following parameters
    mat4 LookAt(vec3 eye, vec3 direction, vec3 up){
        // Handle the translation, but negate the values
        mat4 translation = MatrixMakeTranslation(-mEyePosition);
        
        mat4 look = mat4(mRightVector.x,    mRightVector.y,     mRightVector.z  , 0.0f,
                         mUpVector.x,       mUpVector.y,        mUpVector.z     , 0.0f,
                         mForwardVector.x,  mForwardVector.y,   mForwardVector.z, 0.0f,
                         0.0f, 0.0f, 0.0f, 1.0f);
				look = look.MatrixTranspose();

        return (look * translation); 
    }

    /// Sets the view matrix and also retrieves it
    /// Retrieves the camera view matrix
    mat4 UpdateViewMatrix(){
        mViewMatrix = LookAt(mEyePosition,
                             mEyePosition + mForwardVector,
                             mUpVector);
        return mViewMatrix;
    }

    void MouseLook(int mouseX, int mouseY){
        UpdateViewMatrix();

        static bool firstMouse = true;
        static lastX = 0;
        static lastY = 0;
        if(firstMouse){
            firstMouse = false;
            lastX = mouseX;
            lastY = mouseY;
        }

        float deltaX = (mouseX-lastX)*.01;
        float deltaY = (mouseY-lastY)*.01;

//        import std.stdio;
//        writeln("last : (",lastX,",",lastY,")");
//        writeln("cur  : (",mouseX,",",mouseY,")");
//        writeln("delta: (",deltaX,",",deltaY,")");


        mForwardVector = mForwardVector.Normalize();
        mForwardVector = mat3(MatrixMakeYRotation(deltaX)) * mForwardVector;
		mForwardVector = mForwardVector.Normalize();

		mRightVector = Cross(mForwardVector,mUpVector);
		mRightVector = mRightVector.Normalize();

        mat3 pitchRotation = MatrixMakeRotation(deltaY, mRightVector);
        mForwardVector = (pitchRotation * mForwardVector).Normalize();
        mUpVector = Cross(mRightVector, mForwardVector).Normalize();


        lastX = mouseX;
        lastY = mouseY;

    }

    void MoveForward(){
        UpdateViewMatrix();
        // TODO 
		vec3 direction = mForwardVector;
		direction = direction * 0.2f;		

        SetCameraPosition(mEyePosition.x - direction.x, 
														mEyePosition.y - direction.y,
														mEyePosition.z - direction.z);
    }

    void MoveBackward(){
        UpdateViewMatrix();
        // TODO 
		vec3 direction = mForwardVector;
		direction = direction * 0.2f;		

        SetCameraPosition(mEyePosition.x + direction.x, 
												  mEyePosition.y + direction.y,
												  mEyePosition.z + direction.z);
    }

    void MoveForwardZ(){
        UpdateViewMatrix();
        vec3 direction = vec3(0.0f, 0.0f, -0.2f); 
        SetCameraPosition(mEyePosition + direction);
    }

    void MoveBackwardZ(){
        UpdateViewMatrix();
        vec3 direction = vec3(0.0f, 0.0f, 0.2f); 
        SetCameraPosition(mEyePosition + direction);
    }
    void MoveLeft(){
        UpdateViewMatrix();
        // TODO 
		
        SetCameraPosition(mEyePosition.x - mRightVector.x, 
										      mEyePosition.y - mRightVector.y,
												  mEyePosition.z - mRightVector.z);

    }

    void MoveRight(){
        UpdateViewMatrix();
        // TODO 
        SetCameraPosition(mEyePosition.x + mRightVector.x, 
					      					mEyePosition.y + mRightVector.y,
						  						mEyePosition.z + mRightVector.z);
    }

    void MoveUp(){
        UpdateViewMatrix();
        // TODO 
        SetCameraPosition(mEyePosition.x, 
					     						 mEyePosition.y +0.2f,
						  						 mEyePosition.z);
    }

    void MoveDown(){
        UpdateViewMatrix();
        // TODO 
        SetCameraPosition(mEyePosition.x, 
					     						 mEyePosition.y - 0.2f,
						  						 mEyePosition.z);
    }

    void TurnLeft(float degrees){
        UpdateViewMatrix();
        float radians = degrees.ToRadians;
        mat3 rotation = MatrixMakeYRotation(radians);
        mForwardVector = (rotation * mForwardVector).Normalize();
        mRightVector = Cross(mForwardVector, mUpVector).Normalize();
    }

    void TurnRight(float degrees){
        TurnLeft(-degrees); // just negate the angle
    }

    void TurnUp(float degrees){
        UpdateViewMatrix();
        mRightVector = Cross(mForwardVector, mUpVector).Normalize();

        float radians = degrees.ToRadians;
        mat3 rotation = MatrixMakeRotation(radians, mRightVector);
        mForwardVector = (rotation * mForwardVector).Normalize();
        mUpVector = Cross(mRightVector, mForwardVector).Normalize();
    }

    void TurnDown(float degrees){
        TurnUp(-degrees);
    }
    void TurnUpShear(P3DSlice[] slices){
        // performs a shear transformation rather than a camera tilt
        // does not affect camera, but rather the model
        foreach(slice; slices){
            slice.mMeshNode.LoadIdentity().Shear(-0.5,0.0);
        }
    }
    void TurnDownShear(P3DSlice[] slices){
        // performs a shear transformation rather than a camera tilt
        // does not affect camera, but rather the model
        foreach(slice; slices){
            slice.mMeshNode.LoadIdentity().Shear(0.5,0.0);
        }
    }
}

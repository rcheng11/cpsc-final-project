# cpsc-final-project
Ron Cheng
Yale University
Spring 2025 Senior Project
Advisor: Mike Shah

Title: Lightweight Pseudo 3D Rendering with Sprite Stacks and Normal Mapping

Contents are open source. This project relies on gtk-d, bindbc-loader, and bindbc-opengl and is primarily written in DLang and GLSL. This program has been adapted in part from my advisor Michael Shah's CPSC 409 PSET 9, Yale University. Several. Code that has come from other sources are credited in the comments.

## How to Run
- Ensure that `dlang` is installed.
- From the main folder run `dub` on the command line to load the project
- A window will popup. In the relative file path text box, input `./assets/samples/burger` to load the burger model. This is currently the only model. More models may be added in the future and can be loaded similarly.
- A second GUI window will pop up that currently has not been fully implemented. On that GUI window, **Launch Preview**. Use the keyboard shortcuts defined in the next section to navigate and control the model (see keyboard shortcuts).
- You can have multiple instances of the second GUI window up and display multiple models in multiple windows at once.
- You can exit the program by clicking the red "x" on each of the windows. Clicking the "x" on the first window will terminate all instances of the program.

## Keyboard Shortcuts
- `w`: move up
- `s`: move down
- `a`: move left
- `d`: move right
- `i`: tilt the sprite stack slices down
- `j`: tilt the sprite stack slices up
- `r`: start and stop horizontal rotation of the object
- `e`: start and stop horizontal rotation of the light
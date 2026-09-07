# Interaction

For an interactive demonstration, run the "interaction_demo_level.tscn" scene to see several examples of interactable objects. You can even copy one (or more) into your own scene and modify it to your liking!

## How to build an Interactable Object

1. Add a new child node of "InteractableArea" to your desired scene
2. Set the Collision Layer & Mask to the Interactable layer (4 currently)
3. Add a CollisionShape to your new InteractableArea
4. Position your Area and adjust the Shape to your liking
5. Set the InteractableArea's properties via the Inspector as you see fit
6. In another node's script (such as your root scene node), add a reference to your InteractableArea as a variable
7. Write a new function that will trigger your interaction effect
8. Connect the Area's "interaction_complete" signal to your new function
9. All done!

### Bonus Details

- Use the InteractablePosition layer (5 currently) to build an interactable based on the player's position, rather than the player's looking direction. (eg. a teleportation pad)

- To get a reference to your InteractableArea, I recommend either using `@export` and setting it via the Inspector OR right-clicking your area node to "% Access as unique name" and then Ctrl+Drag that node into your script file for a direct reference. Both of these options ensure that if your scene structure changes, your reference to your Area won't break!

- Can't seem to interact with your new object? - Did you add a CollisionShape node under your new InteractableArea? Did you set the Collision Layer/Mask properties to the Interactable layer?

- General Godot reminder: Don't scale the collision shape in an Area3D! Either change the shape itself or scale a parent node (such as the Area3D) directly. Otherwise Godot's physics get upset.


## How the Interaction system works

In short, the Player has been setup to detect "InteractableArea" nodes. If a valid area is found, the player can interact with it! The Player handles all the nuance of "interaction" generally and the InteractableArea handles what that interaction entails. Create new InteractableArea nodes wherever you like and configure them as needed - then interact to your heart's content!

### InteractableArea

Based on Area3D, a collision zone that identifies a space as "interactable" - typically overlapped on top of a visual indicator, such as a mesh, StaticBody3D, etc.

If you are looking to create a new interactable object, this is the only node you need! Use the info above to see how to build one and you should be good to go!

### InteractionDetector

Simple helpers, also based on Area3D, for detecting InteractableArea nodes. Primarily used on the Player to detect InteractableAreas and report them to the InteractionComponent.

### InteractionComponent

This node acts as a passthrough for all the "interaction" objects. It needs Detectors to find InteractableAreas, and handles communicating that info the UI panel (such as to update the cursor). To account for overlapping interactables, it maintains a queue of objects and decides what the "current" interactable actually is (ie. the most recently found one). This component also taps into the Player's CharacterController to track inputs from the player in order to pass those actions through to the current interactable.

### InteractPromptPanel

A UI panel with a text label that connects to an InteractionComponent. When there is an interactable that can be interacted with, this updates the cursor to a different indicator (also a progress bar) and displays some text from that interactable to indicate the action to perform.

### Player Implementation

- 2 InteractionDetectors that look for various InteractionArea objects
   - one based on the camera's direction
   - one based on the player's standing position.
- If an InteractableArea is detected, the Player's InteractionComponent will track
the details and pass the data through to other nodes.
- The Player's InteractPrompt* nodes connect to the InteractionComponent in order to display relevant HUD visuals for the current interactable object.


### Examples

- The teleport pad uses a positional area that requires the player to be standing within an area in order to trigger it. When initiating a teleport, the pad will disable it's area as well as the destination pad's area to prevent re-teleports. When the player leaves a pad's area (including teleporting away), the area will be re-enabled.
- The ClickLink and ClickSceneChange nodes act as basic helpers to trigger their relevant action (open a web page or change to a new scene). When they are used, a parent node can connect an InteractableArea to these actions. Build a door, give it an InteractableArea and a Click* node, then connect the two via your door's script and you've got a magical door portal to another world!



# UIAnimatorV2 [beta]

## What is it? 🎬

UI Animator Version 2 is a roblox plugin that is used to create stunning user interface animations in Roblox. It builds off the Roblox UI tools to provide the ability to keyframe most properties of UI such as `Position`, `Size`, `Rotation`, `Color`, etc. 

**Please note this project isn't fully complete**

## Example

https://github.com/LeehamsonThe3rd/UIAnimatorV2/assets/62216231/cf1fdc4e-53cb-43d6-8159-d867a7210bf4

https://github.com/LeehamsonThe3rd/UIAnimatorV2/assets/62216231/9b1995e4-b6a2-4bf6-a9e7-fd7fd2b75700

## Downloading the plugin ⬇️

### Download from studio (the preferred way) ⭐
https://create.roblox.com/marketplace/asset/14013326676/UIAnimator-V2

### OR

### Cloning the repo (READ INFO BELOW) 💻

If you're trying to develop additional features you can clone the source and save it as a local plugin.
**HOWEVER there are some special instructions you must follow in the following:**

- `src/server/UIAnimatorV2/src/gui/UIAnimation.lua`
- `src/server/UIAnimatorV2/src/curves` (all files)

The purpose of these instructions are to add instances that cannot normally be serialized with rojo.

## How to use 🤖

UIAnimator V2 is intentionally designed to resemble the built-in Roblox Animation Editor in order to provide ease of use to people who are already experienced with animation tools. If you've never used the Roblox Animation Editor don't fret, here is a diagram showing how to use the tool's features!

### Main controls 🎮
![controls](https://github.com/LeehamsonThe3rd/UIAnimatorV2/assets/62216231/94b36921-6103-49ed-9b19-b6cbed836c5f)

### Top bar media controls ⏯️
![Screenshot 2023-07-09 180520](https://github.com/LeehamsonThe3rd/UIAnimatorV2/assets/62216231/e939d3d6-9210-4dc3-bbb9-d26cb0782704)

Functionality (in respective order) ⏩
- Open context menu to make a new animation, load an animation, or close the opened animation
- To beginning
- Last keyframe (not functional)
- Play in reverse
- Play (normal)
- Next keyframe (not functional)
- To end
- Toggle animation looping

### Tips for managing keyframes ℹ️
You can press the arrow on the side of the hierarchy element to view a list of keyframes from each property

### Making keyframes 💫
This is pretty simple and can be done by selecting a valid member of the `ScreenGui` you are animating and modifying a property **(STRINGS AND ENUMS CANNOT BE ANIMATED YET)**

### Deleting keyframes ❌
Right click the keyframe and select delete, simple as that!

### Moving keyframes 🚋
Click and hold and drag the keyframe to the desired time position on the timeline

### Changing the animation style of a keyframe 👕
Right click the keyframe and hover over `Interpolation Mode` and choose the desired mode (future versions may include a graph editor for full customization)

#### Interpolation Modes 🏃‍♂️
- Linear: moves at a constant speed
- Cubic: moves at a accelerating speed
- Constant: snaps to the next frame

## Documentation 📚

These docs are for the special UIAnimator class only (full docs for the plugin interals will come eventually though)

### Methods ➡️
- `UIAnimator.new()` Creates the UIAnimator class.
- `UIAnimator:Play()` Plays the animation (doesn't reset time).
- `UIAnimator:Stop()` Stops the animation and calls the `Finished` event.
- `UIAnimator:SetLooping(loop: boolean)` Enables (or disables) looping for the animation.
- `UIAnimator:SetSpeed(speed: number)` Sets the playback speed of the animation.
- `UIAnimator:SetLength(length: number)` Sets the length of the animation.
- `UIAnimator:SetTime(time: number)` Sets the current time in the animation.
- `UIAnimator:Destroy()` Destroys the UIAnimator class.

### Events 🚩
- `Finished` Called when the animation has finished or `UIAnimator:Stop()` has been called
- `Looped` Called when the animation ends while looping is enabled on the animation

## Q/A ❓

### Questions I thought you may have 💭

```
Q: How do I change animation speed?
A: You can only change it in script by calling the `UIAnimation:SetSpeed(speed: number)` function

Q: Can I make my animation reversed?
A: Set the speed to -1

Q: How do I change a property without animating it?
A: As annoying as it is just close the animation, there isn't really an easy way to unfocus the animation window

Q: How can I contribute?
A: If you want a feature feel free to add it and send a pull request to the main branch
```

Have any other questions? join my discord and ask: https://discord.gg/zkSP84Sta2

## Issues❗

If you find any issues please send an issue request on this repository's issue tracker, it would greatly help!

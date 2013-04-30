HKViewManipulator
=================

Easy manipulation of UIViews (using built-in Gesture Recognizers).

1. Create an instance of HKViewManipulator, give it a combination of the following flags:
	* HKViewManipulatorTap
	* HKViewManipulatorDoubleTap
	* HKViewManipulatorTranslate
	* HKViewManipulatorScale
	* HKViewManipulatorRotate
2. Give it the Target View, which is the view that is going to be manipulated.
3. Finally, give it the Surface View, which is the view where the touch events are going to be caught (except for the Tap and Double Tap).
4. Optionally, you can specify 3 kinds of constrain:
	* HKScalingConstraint: clamps the scale factor within a range
	* HKRotationConstraint: clamps the rotation angle within a range (in radians)
	* HKTranslationConstraint: constrains the translation along an axis and optionally within a range

Note that HKViewManipulator doesn't change the *frame* of the view but its *transform*
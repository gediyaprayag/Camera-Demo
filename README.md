# Taking Multiple Images in iOS Using UIImagePickerController Camera view.

Try this project code If you want to take multiple `Images` without dismissing the view using UIImagePickerController source type `Camera`.   

In this project I set `showsCameraControls` variable to `false` so that I will hide native camera controls and we can add our custom controlls to handle different camera event such as `takePicture`, `switch camera` and many more.

Now I build custom view to set as a `cameraOverlayView`. In that view I added one `UIButton` and on click of it, It will call UIImagePickerController's `takePicture` method. It will give taken image in delegate method and will be ready to take new image without dismissing the view.

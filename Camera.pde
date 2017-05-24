void setupCamera(){
  
  if(!_use_sony){
    String[] cameras=Capture.list();
    
    if(cameras.length==0){
      println("There are no cameras available for capture.");
      return;
    }
//      println("Available cameras:");
//    for (int i = 0; i < cameras.length; i++) {
//      println(cameras[i]);
//    }
      _camera=new Capture(this,width,height,30);
      _camera.start();     
  }else{
    _camera_sony=new SonyCamera();
    _camera_sony.init(true);
  }
}



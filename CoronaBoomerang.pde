import java.net.*;
import oscP5.*;
import netP5.*;

import http.requests.*;

import processing.video.*;

Parameter _param;
Capture _camera;

Mode _mode;
Timer _timer_count=new Timer(1000,3);
Timer _timer_record;
int _last_millis;

String _video_id;
ArrayList<PImage> _video_frame=new ArrayList<PImage>();


OscP5 _oscP5;
NetAddress _osc_remote;


boolean _use_sony=true;
SonyCamera _camera_sony;


void setup(){
  size(1280,720);
  _param=new Parameter();
  
  _mode=Mode.SLEEP;
  _timer_record=new Timer(1000/_param.CaptureFps,_param.CaptureFrame);
    
  setupCamera();
  setupNetwork();
  setupSerial();
  
  
}
void update(){
   
   // update camera
   if(!_use_sony){
     if(_camera!=null&& _camera.available()) _camera.read();
   }else{
      
   } 
  
  
   int dm=millis()-_last_millis;
   _last_millis+=dm;

   switch(_mode){
    case SLEEP:
      checkSerial();
      break;
    case COUNT:
      _timer_count.update(dm); 
      if(_timer_count.val()>=1) _timer_count.next();     
      if(_timer_count.finish()) changeMode(Mode.RECORD);
      break;
    case RECORD:     
      _timer_record.update(dm);
      if(_timer_record.val()>=1){
         if(!_use_sony){
           PImage img=_camera.get();
           _video_frame.add(img);
         }
         _timer_record.next();
      }
      if(_timer_record.finish()){
        if(_use_sony) _camera_sony.stopRecord();
        changeMode(Mode.PROCESS);      
      }
      break;
    case PROCESS:
      break;
  }
}

void draw(){
 
  update();
  background(0);
  
  if(!_use_sony){
    if(_camera!=null) image(_camera,0,0);
  }else{
    
  }
  
  switch(_mode){
    case SLEEP:
      showMode("SLEEP");
      break;
    case COUNT:
      showMode("COUNT");
      pushStyle();
      textSize(80);
        text(str(3-_timer_count._loop),width/2,height/2);
      popStyle();
      break;
    case RECORD:
      showMode("RECORD");
      pushStyle();
      textSize(80);
        text(str(_timer_record._loop),width/2,height/2);
      popStyle();
      break;
    case PROCESS:
      showMode("PROCESS");
      break;
  }
}
void showMode(String _str){
   pushStyle();
   textSize(12);
      text(_str,12,20);
   popStyle(); 
}


void keyPressed(){
  switch(key){
    case 'r':
      if(_mode==Mode.SLEEP) changeMode(Mode.COUNT);
      break;
    case '1':
    case '2':
    case '3':
      if(_mode==Mode.SLEEP) sendScene(key-'0');
      break;
    case 'a':
      changeMode(Mode.SLEEP);
      break;
    case 'c':
      composeVideo(_video_id);
      break;
      
    case 'R':
      _camera_sony.startRecord();
      break;
    case 'S':
      _camera_sony.stopRecord();
      break;
    case 'F':
      _camera_sony.loadLatestVideo();
      break;
  }    
  
}

void changeMode(Mode mode){
  println("Change Mode= "+mode);
   _mode=mode;
   
   switch(mode){
    case SLEEP:     
      break;
    case COUNT:
      _video_id=createVideoId();
      _timer_count.restart();
      sendCount();
      break;
    case RECORD:
      _timer_record.restart();
      _video_frame.clear();
      
      if(_use_sony) _camera_sony.startRecord();
      
      sendStart();
      break;
    case PROCESS:      
      composeVideo(_video_id);
      uploadVideo(_video_id);
      break;
  }
 
}





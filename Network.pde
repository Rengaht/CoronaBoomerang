void setupNetwork(){
  _oscP5=new OscP5(this,int(_param.RemotePort));
  _osc_remote=new NetAddress(_param.RemoteIp,int(_param.RemotePort));
}

void sendScene(int scene){
  
  _scene_index=scene;
  
  println("send /scene "+scene);
  
  OscMessage mess=new OscMessage("/scene");
  mess.add(scene);
  _oscP5.send(mess,_osc_remote);
}
void sendCount(){
  
  println("send /count");
  
  OscMessage mess=new OscMessage("/count");
  _oscP5.send(mess,_osc_remote);
}
void sendStart(){
  
  println("send /start");
  
  OscMessage mess=new OscMessage("/start");
  _oscP5.send(mess,_osc_remote);
}

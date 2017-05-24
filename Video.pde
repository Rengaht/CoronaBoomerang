String createVideoId(){
   return  _param.VideoFile+str(year())+str(month())+str(day())+str(hour())+str(minute())+str(second());
}

void prepareVideo(String id){
     
    File tmp_folder=new File(_param.OutputFolder+"tmp");
    if(!tmp_folder.exists()){
        tmp_folder.mkdir();
    }
  
    //removeTmpFiles();
  
   if(!_use_sony){
     
      int len=_video_frame.size();
      println(str(len)+" image Saved!");
      
      for(int i=0;i<len;++i){
        _video_frame.get(i).save(_param.OutputFolder+"tmp/tmp"+nf(i,3)+".jpg");
        if(i==0) _video_frame.get(i).save(_param.OutputFolder+id+".jpg");
      }  
   }else{
      _camera_sony.loadLatestVideo();
      
      File ffmpeg_output_msg=new File(_param.OutputFolder+"ffmpeg_output.txt");
      ProcessBuilder pb;
      pb=new ProcessBuilder(_param.FFmpegPath,
        "-y",        
        "-i",_param.OutputFolder+"sonyraw_"+id+".mp4",
        "-r",str(_param.CaptureFps),
        "-vframes",str(_param.CaptureFrame),
        _param.OutputFolder+"tmp/tmp%03d"+".jpg");
      
      pb.redirectErrorStream(true);
      pb.redirectOutput(ffmpeg_output_msg);
      
      try{
        Process p=pb.start(); 
        p.waitFor();   
        
        PImage img_=loadImage(_param.OutputFolder+"tmp/tmp001.jpg");
        img_.save(_param.OutputFolder+id+".jpg");
     
        
      }catch(Exception e){
        println(e);
      } 
      
   }
}

void composeVideo(String id){
  
  File ffmpeg_output_msg=new File(_param.OutputFolder+"ffmpeg_output.txt");
  ProcessBuilder pb;
  
    pb=new ProcessBuilder(_param.FFmpegPath,
        "-y",        
        "-framerate",str(_param.OutputFps),
        "-i",_param.OutputFolder+"tmp/tmp%3d.jpg",     
        "-i",_param.OverlayImage,  
        "-filter_complex","\"[0]reverse[r];[0][r]concat,loop=2:80 [x];[x][1:v]overlay,scale=-1:630\"",
        "-c:v","libx264","-crf",String.valueOf(_param.VideoQuality),
        _param.OutputFolder+id+".mp4");
    
     
  pb.redirectErrorStream(true);
  pb.redirectOutput(ffmpeg_output_msg);
  
  try{
    Process p=pb.start(); 
    p.waitFor();   
    
  }catch(Exception e){
    println(e);
  } 
  
  
}
void composeGif(String id){
   
  saveVideoFrames(id);   
  createPalette(id);
  
  File ffmpeg_output_msg=new File(_param.OutputFolder+"ffmpeg_output.txt");
  ProcessBuilder pb=new ProcessBuilder(_param.FFmpegPath,
    "-y",
    "-framerate","20",
    "-i",_param.OutputFolder+"rtmp/tmp%3d.jpg",
    "-i",_param.OutputFolder+"palette.png",
    "-filter_complex","\"[0]reverse[r];[0][r]concat,loop=0,scale=-1:500:flags=lanczos [x];[x][1:v] paletteuse=diff_mode=rectangle:dither=floyd_steinberg\"",
    _param.OutputFolder+id+".gif");
     
  pb.redirectErrorStream(true);
  pb.redirectOutput(ffmpeg_output_msg);
  
  try{
    Process p=pb.start(); 
    p.waitFor();
   // uploadVideo(id);    
    
  }catch(Exception e){
    println(e);
  } 
  
  
}
void saveVideoFrames(String id){
 
}
void createPalette(String id){
  File ffmpeg_output_msg=new File(_param.OutputFolder+"ffmpeg_output.txt");
  ProcessBuilder pb=new ProcessBuilder(_param.FFmpegPath,
    "-y",
    "-framerate","20",
    "-i",_param.OutputFolder+"tmp%3d.jpg",
    "-filter_complex","\"[0]reverse[r];[0][r]concat,loop=0,scale=-1:500:flags=lanczos,palettegen=max_colors=128:stats_mode=diff\"",
    _param.OutputFolder+"palette.png");
     
  pb.redirectErrorStream(true);
  pb.redirectOutput(ffmpeg_output_msg);
  
  try{
    Process p=pb.start(); 
    p.waitFor();
   // uploadVideo(id);    
    
  }catch(Exception e){
    println(e);
  } 
  
  
}


void uploadVideo(String id){
  
  println("Upload video...");
  
  String file_path=_param.OutputFolder+id+".mp4";
  File file=new File(file_path);
  if(!file.exists() || file.isDirectory()){
    println("No such file:"+file_path);  
    changeMode(Mode.SLEEP);
    return;
  }
  
  PostRequest post = new PostRequest(_param.ServerURL+"action.php");
  post.addData("action", "upload_video");   
  post.addData("guid",id);  
  post.addFile("file",file_path);
  //post.send();
  
  writeOrderFile(id);
  
  println("All finish...");
  
  changeMode(Mode.SLEEP);
  
}

void writeOrderFile(String id){
  
  saveStrings(_param.OrderFolder+id,new String[]{}); 
   
}

void removeTmpFiles(){
   println("Remove tmp files...");
   
   File tmp_dir=new File(_param.OutputFolder+"tmp");  
   String[] tmps=tmp_dir.list();
   for(String s:tmps){
      File f_=new File(tmp_dir.getPath(),s);
      f_.delete(); 
   }
}




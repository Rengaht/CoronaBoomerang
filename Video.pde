String createVideoId(){
   return  _param.VideoFile+str(year())+str(month())+str(day())+str(hour())+str(minute())+str(second());
}
void composeVideo(String id){
  
  File ffmpeg_output_msg=new File(_param.OutputFolder+"ffmpeg_output.txt");
  ProcessBuilder pb;
  
  if(_use_sony){
    saveVideoFrames(id);
    pb=new ProcessBuilder(_param.FFmpegPath,
        "-y",        
        "-i",_param.OutputFolder+"sonyraw_"+id+".mp4",
        "-filter_complex","\"[0]reverse[r];[0][r]concat,loop=5:100,scale=-1:630\"",
        "-c:v","libx264","-crf",String.valueOf(_param.VideoQuality),
        _param.OutputFolder+id+".mp4");
    
    
  }else{
    _camera_sony.loadLatestVideo();
    pb=new ProcessBuilder(_param.FFmpegPath,
        "-y",        
        "-framerate","20",
        "-i",_param.OutputFolder+"tmp%3d.jpg",
        "-filter_complex","\"[0]reverse[r];[0][r]concat,loop=5:100,scale=-1:630\"",
        "-c:v","libx264","-crf",String.valueOf(_param.VideoQuality),
        _param.OutputFolder+id+".mp4");
    
  }
 
     
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
void composeGif(String id){
   
  saveVideoFrames(id);   
  createPalette(id);
  
  File ffmpeg_output_msg=new File(_param.OutputFolder+"ffmpeg_output.txt");
  ProcessBuilder pb=new ProcessBuilder(_param.FFmpegPath,
    "-y",
    "-framerate","20",
    "-i",_param.OutputFolder+"tmp%3d.jpg",
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
  int len=_video_frame.size();
  println(str(len)+" image Saved!");
  
  for(int i=0;i<len;++i){
    _video_frame.get(i).save(_param.OutputFolder+"tmp"+nf(i,3)+".jpg"); 
  }
  
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
  post.send();
  
  writeOrderFile(id);
  
  changeMode(Mode.SLEEP);
  
}

void writeOrderFile(String id){
  
  saveStrings(_param.OrderFolder+id,new String[]{}); 
   
}


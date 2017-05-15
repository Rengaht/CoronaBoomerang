

class Parameter{
  
  String OutputFolder; //output video files
  String OrderFolder;
  
  String VideoFile;
  String FFmpegPath;
  
  String ServerURL;
  
  
  //video
  int CaptureFrame;
  int CaptureFps;
  int OutputFps;
  int OutputLoop;
  
  int VideoQuality;
  
  
  String RemoteIp;
  String RemotePort;
  
  
  Parameter(){
     readParam();
     
     
  }
  
  void readParam(){
    
    XML param_xml;
    param_xml=loadXML("data\\param_file.xml");
    if(param_xml==null){
      println("No existing fil, write param...");
      writeParam();
      return;
    }
    println("__Read Parameters__");
    
    
    OutputFolder=param_xml.getChildren("OUTPUT_FOLDER")[0].getContent();
    println("__OutputFolder= "+OutputFolder);
    OrderFolder=param_xml.getChildren("ORDER_FOLDER")[0].getContent();
    println("__OutputFolder= "+OrderFolder);

    VideoFile=param_xml.getChildren("VIDEO_FILE")[0].getContent();
    println("__VideoFile= "+VideoFile);
    

    FFmpegPath=param_xml.getChildren("FFMPEG_PATH")[0].getContent();
    println("__FFmpegPath= "+FFmpegPath);
    
    ServerURL=param_xml.getChildren("SERVER_URL")[0].getContent();
    println("__ServerURL= "+ServerURL);    
    
    CaptureFrame=parseInt(param_xml.getChildren("CAPTURE_FRAME")[0].getContent());
    CaptureFps=parseInt(param_xml.getChildren("CAPTURE_FPS")[0].getContent());
    OutputFps=parseInt(param_xml.getChildren("OUTPUT_FPS")[0].getContent());
    OutputLoop=parseInt(param_xml.getChildren("OUTPUT_LOOP")[0].getContent());
    println("__Capture= "+CaptureFrame+" / "+CaptureFps+"fps");
    println("__Output= "+OutputLoop+" times / "+OutputFps+"fps");
  
    VideoQuality=parseInt(param_xml.getChildren("VIDEO_QUALITY")[0].getContent());
    println("__VideoQuality= "+VideoQuality);
         
    RemoteIp=param_xml.getChildren("REMOTE_IP")[0].getContent();
    println("__RemoteIP= "+RemoteIp);    
    RemotePort=param_xml.getChildren("REMOTE_PORT")[0].getContent();
    println("__RemotePort= "+RemotePort);
    
  }
  
  void writeParam(){
    XML xml=new XML("PARAM");
       
     

    XML pf=xml.addChild("OUTPUT_FOLDER");
    pf.setContent(OutputFolder);    
            
    XML of=xml.addChild("ORDER_FOLDER");
    of.setContent(OrderFolder);    

    
    XML vf=xml.addChild("VIDEO_FILE");
    vf.setContent(VideoFile);
    
    XML fp=xml.addChild("FFMPEG_PATH");
    fp.setContent(FFmpegPath);
    

    XML surl=xml.addChild("SERVER_URL");
    surl.setContent(ServerURL);             
  
    XML rip=xml.addChild("REMOTE_IP");
    rip.setContent(RemoteIp);             
    XML rpt=xml.addChild("REMOTE_PORT");
    rpt.setContent(RemotePort);

    XML cf=xml.addChild("CAPTURE_FRAME");
    cf.setContent(str(CaptureFrame));
    XML cp=xml.addChild("CAPTURE_FPS");
    cp.setContent(str(CaptureFps));
    
    XML ol=xml.addChild("OUTPUT_LOOP");
    ol.setContent(str(OutputLoop));
    
    XML op=xml.addChild("OUTPUT_FPS");
    op.setContent(str(OutputFps));
    
      
    XML vq=xml.addChild("VIDEO_QUALITY");
    vq.setContent(str(VideoQuality));
    
    
    
             
    saveXML(xml,"data\\param_file.xml");
    
  }
  
}

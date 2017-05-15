class SonyCamera{
  String _device_url;
  String _service_url;
  
  boolean _use_aclient=false;
  //boolean _use_default_address;
  
  void init(boolean use_default){
     println("Init Camera...");
     
     if(!use_default){
     
       _device_url=getDeviceDescriptionURL();
       println("Got Device Descript URL: "+_device_url);
       
       _service_url=getServiceURL(_device_url);     
       println("Got Camera Service URL: "+_service_url);
     }else{
        _service_url="http://192.168.122.1:8080/sony"; 
     }
     sendRequest("startRecMode",null);
  }
  
  String getDeviceDescriptionURL(){
    /* create byte arrays to hold our send and response data */
    byte[] sendData = new byte[1024];
    byte[] receiveData = new byte[1024];

    /* our M-SEARCH data as a byte array */
    //String MSEARCH = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: \"ssdp:discover\"\nST: roku:ecp\n"; 
    String MSEARCH="M-SEARCH * HTTP/1.1\r\n"
                +String.format("HOST: %s:%d\r\n", "239.255.255.250",1900)
                +String.format("MAN: \"ssdp:discover\"\r\n")
                +String.format("MX: %d\r\n", 1)
                +String.format("ST: %s\r\n", "urn:schemas-sony-com:service:ScalarWebAPI:1") + "\r\n";
    sendData = MSEARCH.getBytes();
    
    try{
            
      DatagramPacket sendPacket=new DatagramPacket(sendData, sendData.length, InetAddress.getByName("239.255.255.250"), 1900);
  
      DatagramSocket clientSocket=new DatagramSocket();
      clientSocket.send(sendPacket);
      println("send packet!");
      
      DatagramPacket receivePacket=new DatagramPacket(receiveData, receiveData.length);
      clientSocket.receive(receivePacket);
      println("receive packet!");
      
      String response=new String(receivePacket.getData());          
      System.out.println(response);
      
      String dd_url=findHeaderValue(response,"LOCATION");
      
      clientSocket.close();
      return dd_url;
      
      
    }catch(Exception e){
       e.printStackTrace(); 
       return "";
    }
   
  }
  String getServiceURL(String dd_url){
   
    XML xml=loadXML(dd_url);
    //println(xml); 
    //XML root=xml.getChildren("root")[0];
    XML device=xml.getChildren("device")[0];
    XML deviceInfo=device.getChildren("av:X_ScalarWebAPI_DeviceInfo")[0];
    XML servicelist=deviceInfo.getChildren("av:X_ScalarWebAPI_ServiceList")[0];
    XML[] service=servicelist.getChildren("av:X_ScalarWebAPI_Service");
    
    for(XML s:service){
      XML type=s.getChildren("av:X_ScalarWebAPI_ServiceType")[0];
      if(type.getContent().equals("camera")){
         // println("camera service: "+s);
         return s.getChildren("av:X_ScalarWebAPI_ActionList_URL")[0].getContent(); 
      }
    }
    return "";
  }
  
  
  String findHeaderValue(String ssdpMessage, String parameterName){
    parameterName+=':';
    int start=ssdpMessage.indexOf(parameterName);
    if(start==-1){
        println("[ERR] Header not found: " + parameterName);
        return "";
    }
    start+=parameterName.length();
    
    int end=ssdpMessage.indexOf("\r\n", start);
    if(end == -1){
      println("[ERR] Every header should end with '\\r\\n'");
      return "";
    }    
    
    return ssdpMessage.substring(start, end).trim();
  }
  String sendRequest(String method,JSONArray param){
    return sendRequest("camera",method,param,"1.0");
  }  
  String sendRequest(String dest,String method,JSONArray param,String version){
    println("Send Request: "+method+" ...");
    
    JSONObject jmethod=new JSONObject();
    jmethod.setString("method",method);
    
    //JSONArray p_=new JSONArray();
    //if(param!=null) p_.setJSONObject(0,param);
    if(param==null) param=new JSONArray();
    jmethod.setJSONArray("params",param);
    
    jmethod.setInt("id",1);
    jmethod.setString("version",version);
    //println(jmethod);
    
//    PostRequest request=new PostRequest(_service_url+"/"+dest);
//    request.addData("method",method);
//    request.addData("params",param.toString());
//    request.addData("id",str(1));
//    request.addData("version",version);        
//    request.send();
//    println("result: \n"+request.getContent());
//    return request.getContent();
     
    HttpClient client=new HttpClient();
    try{
      String result=client.fetchTextByPost(_service_url+"/"+dest,jmethod.toString());
      println("result: \n"+result);
      return result;
      
    }catch(Exception e){
       e.printStackTrace(); 
       return "";
    }
  }
  
  void startRecord(){
    
     JSONArray mp_=new JSONArray();
     mp_.append("movie");
     
     JSONArray sval=new JSONArray();
     sval.append("Remote Shooting");    
     sendRequest("setCameraFunction",sval);    
   
   
     sendRequest("startMovieRec",null);
      
  }
  void stopRecord(){
     sendRequest("stopMovieRec",null);    
  }
  void loadLatestVideo(){
    
   
    JSONArray sval=new JSONArray();
    sval.append("Contents Transfer");    
    sendRequest("setCameraFunction",sval);    

    
    JSONObject fparam=new JSONObject();
    fparam.setString("uri","storage:memoryCard1");
    fparam.setInt("stIdx",0);
    fparam.setInt("cnt",1);
    fparam.setString("view","flat");
    fparam.setString("sort","descending");
    JSONArray fval=new JSONArray();
    fval.append(fparam);
    
    String info_str_=sendRequest("avContent","getContentList",fval,"1.3");
    
    //get file
    String url_=null;
    try{
      JSONObject info_=parseJSONObject(info_str_).getJSONArray("result").getJSONArray(0).getJSONObject(0);
      url_=info_.getJSONObject("content").getJSONArray("original").getJSONObject(0).getString("url");
      
      println("File url= "+url_);
    }catch(Exception e){
       e.printStackTrace(); 
    }
     
    if(url_==null){
      println("Get file url error!!!");
      return;
    }   
    HttpClient client=new HttpClient();
    try{
      client.getFile(url_,_param.OutputFolder+"sonyraw_"+_video_id+".mp4");      
    }catch(Exception e){
       e.printStackTrace(); 
    }

  }
}

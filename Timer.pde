class Timer{
  int _due;
  int _time;
  boolean _run;
  int _loop;
  int _dest_loop;
  
  Timer(int due,int loop){
    _due=due; 
    _dest_loop=loop;
  }
  void reset(){
      _time=0;
      _loop=0;
  }
  void start(){
    _run=true;
  }
 
  void restart(){
      reset();
      start();
  }
  void update(int dt){
    if(!_run) return;
    if(_time<_due) _time+=dt;    
  }
  void next(){
     _time=0; 
     _loop++;
  }
  float val(){
     return (float)_time/(float)_due; 
  }
  boolean finish(){
    return _loop==_dest_loop;
  }
  
}

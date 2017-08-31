class Aurora extends LXPattern {
  class Wave extends LXLayer {
    
    //wave vertical o
    final private SinLFO rate1 = new SinLFO(200000, 290000, 17000);
    final private SinLFO off1 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate1);
    final private SinLFO wth1 = new SinLFO(7, 12, 30000);

    final private SinLFO rate2 = new SinLFO(228000, 310000, 22000);
    final private SinLFO off2 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate2);
    final private SinLFO wth2 = new SinLFO(15, 20, 44000);

    final private SinLFO rate3 = new SinLFO(160000, 289000, 14000);
    final private SinLFO off3 = new SinLFO(-2*TWO_PI, 2*TWO_PI, rate3);
    final private SinLFO wth3 = new SinLFO(12, 140, 40000);


    Wave(LX lx) {
      super(lx);      
      addModulator(rate1.randomBasis()).start();
      addModulator(rate2.randomBasis()).start();
      addModulator(rate3.randomBasis()).start();
      addModulator(off1.randomBasis()).start();
      addModulator(off2.randomBasis()).start();
      addModulator(off3.randomBasis()).start();
      addModulator(wth1.randomBasis()).start();
      addModulator(wth2.randomBasis()).start();
      addModulator(wth3.randomBasis()).start();
    }

    public void run(double deltaMs) {
      for (LXPoint p : model.points) {
        
        float vy1 = model.yRange/4 * sin(off1.getValuef() + (p.x - model.cx) / wth1.getValuef());
        float vy2 = model.yRange/4 * sin(off2.getValuef() + (p.x - model.cx) / wth2.getValuef());
        float vy = model.ay + vy1 + vy2;
        
        float thickness = 16 + 9 * sin(off3.getValuef() + (p.x - model.cx) / wth3.getValuef());
        float ts = thickness/1.2;

        addColor(p.index, LXColor.hsb(
        (lx.getBaseHuef() + (p.x / model.xRange) * 66) % 360,
        min(40, (100/ts)*abs(p.y - vy)), 
        max(0, 100 - (100/thickness)*abs(p.y - vy))
        ));
      }
    }
   
  }

  Aurora(LX lx) {
    super(lx);
    for (int i = 0; i < 1; ++i) {
      addLayer(new Wave(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}



class Transporter extends LXPattern {
  
  final float size = 3;
  final float vLow = 1.8;
  final float vHigh = 3.6;
  final int num = 180;
  
  
  class Beam extends LXLayer {
    
    private final float wth = random(2,4);
    
    private final SinLFO jerk = new SinLFO(-0.45, 0.5, 21*SECONDS);

    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, jerk);
     
    Beam(LX lx) {
      super(lx);
      addModulator(jerk.randomBasis()).start();
      addModulator(xPos).start();
      addModulator(yPos).start();
      init();
    }

    public void run(double deltaMs) {
      boolean touched = false;
      for (LXPoint p : model.points) {
          float dx = abs(p.x - xPos.getValuef());
          float dy = abs(p.y/wth - yPos.getValuef());
          float b = 16 - (16/size) * max(dx, dy);
        if (b > 0) {
          touched = true;
          blendColor(p.index, LXColor.hsb(
            0,
            0, 
            b), LXColor.Blend.ADD);
        }
      }
      if (!touched) {
        init();
      }
      lx.cycleBaseHue(9.6*MINUTES);
    }

    private void init() {
      xPos.setValue(random(model.xMin-5.25, model.xMax+5.25));
      yPos.setValue(random(model.yMin-3, model.yMin-3));  
      yPos.setVelocity(random(vLow, vHigh));
      
    }
  }
  
  Transporter(LX lx) {
    super(lx);
    for (int i = 0; i < num; ++i) {
      addLayer(new Beam(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    
  }
    
}



class ColorSwatches extends LXPattern{

  class Swatch extends LXLayer {

    private final SinLFO sync = new SinLFO(8*SECONDS, 24*SECONDS, 76*SECONDS);
    private final SinLFO bright = new SinLFO(-100,100, sync);
    private final SinLFO sat = new SinLFO(45,75, sync);
    private final TriangleLFO hueValue = new TriangleLFO(0, 22, sync);

    private int sPixel;
    private int fPixel;
    private float hOffset;

    Swatch(LX lx, int s, int f, float o){
      super(lx);
      sPixel = s;
      fPixel = f;
      hOffset = o;
      addModulator(sync.randomBasis()).start();
      addModulator(bright.randomBasis()).start();
      addModulator(sat.randomBasis()).start();
      addModulator(hueValue.randomBasis()).start();
    }

    public void run(double deltaMs) {
      float s = sat.getValuef();
      float b = constrain(bright.getValuef(), 0, 100);

      for(int i = sPixel; i < fPixel; i++){
        blendColor(i, LXColor.hsb(
          lx.getBaseHuef() + hueValue.getValuef() + hOffset,
          //lx.getBaseHuef() + hOffset,
          s,
          b
          ), LXColor.Blend.LIGHTEST);
        }
    }

  }

  ColorSwatches(LX lx){
   super(lx);
   //size of each swatch in pixels
    final int section = 5;
   for(int s = 0; s <= model.size-section; s+=section){
     if((s+section) % (section*2) == 0){
     addLayer(new Swatch(lx, s, s+section, 8));
     }else{
       addLayer(new Swatch(lx, s, s+section, 0));
     }  
   }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    lx.cycleBaseHue(3.37*MINUTES);
  }

}
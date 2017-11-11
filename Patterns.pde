
/******************

Color Swatches

*******************/

class ColorSwatches extends LXPattern{

  class Swatch extends LXLayer {

    private final SinLFO sync = new SinLFO(6*SECONDS, 10*SECONDS, 39*SECONDS);
    private final SinLFO bright = new SinLFO(-80,100, sync);
    private final SinLFO sat = new SinLFO(45,75, sync);
    private final TriangleLFO hueValue = new TriangleLFO(0, 26, sync);

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

  ColorSwatches(LX lx, int num_sec){
   super(lx);
   //size of each swatch in pixels
    final int section = num_sec;
   for(int s = 0; s <= model.size-section; s+=section){
     if((s+section) % (section*2) == 0){
     addLayer(new Swatch(lx, s, s+section, 16));
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



/******************

Spirals

*******************/

class Spirals extends LXPattern {
  class Wave extends LXLayer {
    
    final private SinLFO rate1 = new SinLFO(200000*2, 290000*2, 17000);
    final private SinLFO off1 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate1);
    final private SinLFO wth1 = new SinLFO(7, 12, 30000);

    final private SinLFO rate2 = new SinLFO(228000*1.6, 310000*1.6, 22000);
    final private SinLFO off2 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate2);
    final private SinLFO wth2 = new SinLFO(15, 20, 44000);

    final private SinLFO rate3 = new SinLFO(160000, 289000, 14000);
    final private SinLFO off3 = new SinLFO(-2*TWO_PI, 2*TWO_PI, rate3);
    final private SinLFO wth3 = new SinLFO(12, 140, 40000);

    final private float hOffset;
    
    Wave(LX lx, float o) {
      super(lx);
      hOffset = o;
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
        
        float thickness = 3 + 1.5 * sin(off3.getValuef() + (p.x - model.cx) / wth3.getValuef());
        float ts = thickness/1.2;

        blendColor(p.index, LXColor.hsb(
        (lx.getBaseHuef() + hOffset + (p.x / model.xRange) * 90) % 360,
        min(65, (100/ts)*abs(p.y - vy)), 
        max(0, 40 - (40/thickness)*abs(p.y - vy))
        ), LXColor.Blend.ADD);
      }
    }
   
  }

  Spirals(LX lx) {
    super(lx);
    for (int i = 0; i < 10; ++i) {
      addLayer(new Wave(lx, i*6));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    lx.cycleBaseHue(5.42*MINUTES);
  }
}

/******************

Shadows

*******************/


class Shadows extends LXPattern {
  
  final float size = 10;
  final float vLow = 5;
  final float vHigh = 14;
  final int bright = 22;
  final int num = 12;
  
  
  class LeftShadow extends LXLayer {
    
    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, 0);
     
    LeftShadow(LX lx) {
      super(lx);
      addModulator(xPos).start();
      addModulator(yPos).start();
      init();
    }

    public void run(double deltaMs) {
      boolean touched = false;
      for (LXPoint p : model.points) {
          float b = bright - (bright / size)*dist(p.x/2.2, p.y, xPos.getValuef(), yPos.getValuef());
          float s = b/3;
        if (b > 0) {
          touched = true;
          blendColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + (p.y / model.yRange) * 90) % 360,
            min(65, (100/s)*abs(p.y - yPos.getValuef())), 
            b), LXColor.Blend.ADD);
        }
      }
      if (!touched) {
        init();
      }
    }

    private void init() {
      xPos.setValue(random(model.xMin-9, model.xMin-10));
      yPos.setValue(random(model.yMin-5, model.yMax+5));  
      xPos.setVelocity(random(vLow, vHigh));
      
    }
  }
  
  class RightShadow extends LXLayer {

    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, 0);
     
    RightShadow(LX lx) {
      super(lx);
      addModulator(xPos).start();
      addModulator(yPos).start();
      init();
    }

    public void run(double deltaMs) {
      boolean touched = false;
      for (LXPoint p : model.points) {
          float b = bright - (bright / size)*dist(p.x/2, p.y, xPos.getValuef(), yPos.getValuef());
          float s = b/3;
        if (b > 0) {
          touched = true;
          blendColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + (p.y / model.yRange) * 90) % 360,
            min(65, (100/s)*abs(p.y - yPos.getValuef())), 
            b), LXColor.Blend.ADD);
        }
      }
      if (!touched) {
        init();
      }

    }

    private void init() {
      xPos.setValue(random(model.cx+9, model.cx+10));
      yPos.setValue(random(model.yMin-5, model.yMax+5));  
      xPos.setVelocity(random(-vLow,- vHigh));
      
    }
  }
  
  Shadows(LX lx) {
    super(lx);
    for (int i = 0; i < num; ++i) {
      addLayer(new LeftShadow(lx));
      addLayer(new RightShadow(lx));
      lx.cycleBaseHue(60*MINUTES);
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    
  }
    
}
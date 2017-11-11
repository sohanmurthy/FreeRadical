//Connects to local Fadecandy server and maps P3LX points to physical pixels 

FadecandyOutput buildOutput() {
  FadecandyOutput output = null;
  int[] pointIndices = buildPoints();
  output = new FadecandyOutput(lx, "127.0.0.1", 7890, pointIndices);
  lx.addOutput(output);
  return output;
}

//Function that maps point indices to pixels on led strips
int[] buildPoints() {
  int pointIndices[] = new int[480];
  int i = 0;
  for (int strips = 0; strips < 8; strips = strips + 1) {
    for (int pixels_per_strip = 0; pixels_per_strip < 60; pixels_per_strip = pixels_per_strip + 1) {
          pointIndices[i] = (pixels_per_strip+60*strips);
      i++;
    } 
  }
  return pointIndices; 
}
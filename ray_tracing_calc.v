module ray_tracing_calc#(parameter WIDTH=32)(ax,ay,az,bx,by,bz,r,px1,px2,py1,py2,pz1,pz2);
input signed [WIDTH-1:0]ax,ay,az,bx,by,bz,r;
wire signed [WIDTH-1:0]A,B,C,D,sqrtD;
wire signed [WIDTH-1:0]t1,t2;
output signed [WIDTH-1:0]px1,px2,py1,py2,pz1,pz2;

assign A=bx*bx + by*by + bz*bz;
assign B=(ax*bx + ay*by + az*bz)<<<1;
assign C=ax*ax + ay*ay + az*az - r*r;
assign D=B*B - (A<<<2)*C;

sqrt_module sqrt_unit(.in(D),.out(sqrtD));
divider_module div1(.num(-B + sqrtD), .den(A<<<1), .out(t1));
divider_module div2(.num(-B - sqrtD), .den(A<<<1), .out(t2));

assign px1=ax+(bx*t1>>>16);
assign px2=ax+(bx*t2>>>16);
assign py1=ay+(by*t1>>>16);
assign py2=ay+(by*t2>>>16);
assign pz1=az+(bz*t1>>>16);
assign pz2=az+(bz*t2>>>16);
endmodule

module divider_module #(parameter WIDTH = 32)(num,den,out);
input wire [WIDTH-1:0]num,den;
output reg [WIDTH-1:0]out;

reg [WIDTH-1:0]remainder;
integer i;

always@(*)
begin
  out=0;
  remainder=0;
  for(i=WIDTH-1;i>=0;i=i-1)
  begin
    remainder=(remainder<<1) | (num>>i & 1'b1);
    if(remainder>=den)
    begin
      remainder=remainder-den;
      out[i]=1'b1;
    end
  end  
end
endmodule

module sqrt_module #(parameter WIDTH=32)(in,out);
input wire [WIDTH-1:0]in;
output reg [WIDTH/2-1:0]out;

reg [WIDTH-1:0]bit;
reg [WIDTH-1:0]temp;

always@(*)
begin
  out=0;
  bit=1<<(WIDTH-2);
  temp=in;
  while(bit>0)
  begin
    if(temp>=(out+bit))
    begin
      temp=temp-(out+bit);
      out=(out>>1)+bit;    
    end
   else
   begin
      out=out>>1;
   end 
   bit=bit>>2;
  end
end
endmodule


--Sam Brandt

--Code that allows a user to interact and play with a jelly like
--square while moving around the environment

require "CloseButton"

ay=0.1
cx,cy=0,0
s,k=0,0
plocx,plocy=284,160

function newball(x,y)
   local o={}
   o.x=x
   o.y=y
   o.px=x
   o.py=y
   o.touched=false
   function o:update()
      local tmpx=self.x
      local tmpy=self.y
      if (not self.touched) then
         local dir={plocx-self.x,plocy-self.y}
         dist=math.sqrt((plocx-self.x)^2+(plocy-self.y)^2)
         local acc={10*(dir[1]/dist^2),10*(dir[2]/dist^2)}
         self.x=self.x+(self.x-self.px)+acc[1]
         self.y=self.y+(self.y-self.py)+acc[2]
         if self.y>310 and false then
            self.y=310
         end
         if self.x>558 and false then
            self.x=558
         end
         if self.x<10 and false then
            self.x=10
         end
         if dist<50 then
            self.x=plocx-(dir[1]/dist)*50
            self.y=plocy-(dir[2]/dist)*50
         end
      end
      self.px=tmpx
      self.py=tmpy
   end
   return o
end

function newspring(ball1,ball2,stabl)
   local o={}
   o.ball1=ball1
   o.ball2=ball2
   o.prevdist=math.sqrt((ball1.x-ball2.x)^2+(ball1.y-ball2.y)^2)
   if stabl~=nil then
      o.stabl=stabl
   else
      o.stabl=o.prevdist
   end
   function o:update()
      local dist=math.sqrt((self.ball1.x-self.ball2.x)^2+(self.ball1.y-self.ball2.y)^2)
      local theta=math.atan2((self.ball1.y-self.ball2.y),(self.ball1.x-self.ball2.x))
      local deltad=(self.stabl-dist)*0.2-(dist-self.prevdist)*0.16
      if not self.ball1.touched then
         self.ball1.x=self.ball1.x+deltad*math.cos(theta)
         self.ball1.y=self.ball1.y+deltad*math.sin(theta)
      end
      if not self.ball2.touched then
         self.ball2.x=self.ball2.x+deltad*math.cos(theta+math.pi)
         self.ball2.y=self.ball2.y+deltad*math.sin(theta+math.pi)
      end
      self.prevdist=dist
      o.stabl=o.stabl
   end
   return o
end

function init()
   balls={}
   springs={}
   for i=1,5 do
      for j=1,5 do
         balls[#balls+1]=newball(i*40,j*40)
      end
   end
   for i=1,4 do
      for j=1,5 do
         springs[#springs+1]=newspring(balls[(j-1)*5+i],balls[(j-1)*5+i+1],40)
         springs[#springs+1]=newspring(balls[(i-1)*5+j],balls[i*5+j])
      end
   end
   for i=1,4 do
      for j=1,4 do
         springs[#springs+1]=newspring(balls[(i-1)*5+j],balls[i*5+j+1])
         springs[#springs+1]=newspring(balls[i*5+j],balls[(i-1)*5+j+1])
      end
   end
end

function close.begin(x,y)
   local balltouched=nil
   for i=1,#balls do
      if x>=balls[i].x+cx-20 and x<=balls[i].x+cx+20 and y>=balls[i].y+cy-20 and y<=balls[i].y+cy+20 then
         balls[i].touched=true
         balltouched=true
         a,b=x,y
         bindex=i
         break
      end
   end
   if not balltouched then
      att=true
      s,k=x,y
   end
end

function close.during(x,y)
   if bindex~=nil then
      balls[bindex].x=balls[bindex].x+(x-a)
      balls[bindex].y=balls[bindex].y+(y-b)
      a,b=x,y
   else
      cx,cy=cx+(x-s),cy+(y-k)
      s,k=x,y
   end
end

function close.done(x,y)
   if bindex~=nil then
      balls[bindex].x=balls[bindex].x+(x-a)
      balls[bindex].y=balls[bindex].y+(y-b)
      balls[bindex].touched=false
      bindex=nil
   end
   att=false
end

function close.render()
   draw.clear(draw.black)
   draw.fillcircle(plocx+cx,plocy+cy,40,draw.green)
   for i=1,#springs do
      draw.line(springs[i].ball1.x+cx,springs[i].ball1.y+cy,springs[i].ball2.x+cx,springs[i].ball2.y+cy,{0,1,1,1})
   end
   for i=1,#balls do
      draw.fillcircle(balls[i].x+cx,balls[i].y+cy,8,draw.red)
   end
   --[[for i=1,4 do
      for j=1,4 do
         draw.filltriangle(balls[(i-1)*5+j].x,balls[(i-1)*5+j].y,balls[i*5+j].x,balls[i*5+j].y,balls[i*5+j+1].x,balls[i*5+j+1].y,draw.green)
         draw.filltriangle(balls[(i-1)*5+j].x,balls[(i-1)*5+j].y,balls[(i-1)*5+j+1].x,balls[(i-1)*5+j+1].y,balls[i*5+j+1].x,balls[i*5+j+1].y,draw.green)
      end
   end]]
end

t=os.time()
init()
function close.update()
   if os.time()-5>t then
      --ay=100
   end
   for i=1,#balls do
      balls[i]:update()
   end
   for i=1,#springs do
      springs[i]:update()
   end
end

close.main()

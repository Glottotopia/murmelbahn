
spurweite=10; 
gleisdicke=3; //4 is too much 
fluegelbreite=10;
fluegelhoehe=7;
fluegeldicke=1;
schwellenbreite=10;
schwellensafety=6;// Abstand zwischen Hakenansatz und erster Schwelle
rotationangle=80;
hakenrotationradius=3;
sechseckkantenlaenge=35;
sechseckhoehe=2*sqrt(sechseckkantenlaenge*sechseckkantenlaenge-(0.5*sechseckkantenlaenge)*(0.5*sechseckkantenlaenge));
fn=60;
plaettchenhoehe=10;
fahrbahnhoehe=4;
fahrbahnbreite=spurweite+6;
module prism(w,d,h,extraw=0){
//   polyhedron(
////           points=[[0,0,0], [0,0,h], [w,0,0], [0,d,0], [0,d,h], [w,d,0]],
////           faces=[[0,1,2],[3,4,5],[0,1,4,3],[1,2,5,4],[2,0,3,5]]
//           points=[
//                [0,0,0], [0,0,h], [extraw,0,h], [w,0,0],
//                [0,d,0], [0,d,h], [extraw,d,h], [w,d,0]
//            ],
//           faces=[[0,1,2,3],[4,5,6,7],
//                  [0,1,5,4],[1,2,6,5],[2,3,7,6],[3,4,0,7]]
//           );  
   polyhedron( 
           points=[
                [0,0,0], [0,0,h], [extraw,0,h], [w,0,0],
                [0,d,0], [0,d,h], [extraw,d,h], [w,d,0]
            ],
           faces=[[0,1,2,3],[4,5,6,7],
                  [0,1,5,4],[1,2,6,5],[2,3,7,6],[3,4,0,7]]
           ); 
    cube([w,d,h*.66]);
   }
       

module gleis(laenge, spurweite, extra_schwellen=0){
    translate([0,0, fahrbahnhoehe])
    schiene(laenge-hakenrotationradius);
    translate([0,spurweite, fahrbahnhoehe])
    schiene(laenge-hakenrotationradius);
    faecher=1+extra_schwellen; 
    schwellenoffset=(laenge-2*schwellensafety-schwellenbreite)/faecher;
    for (i=[0:faecher]){
        translate([schwellensafety+schwellenoffset*i-hakenrotationradius/2,0,fahrbahnhoehe-1])
        schwelle(spurweite);
    }     
//    color("red")
//    translate([laenge-schwellensafety,0,0])
//    schwelle(spurweite);
    translate([-hakenrotationradius/2,0,fahrbahnhoehe])
    fluegel();
//       
    translate([laenge-hakenrotationradius/2,0,fahrbahnhoehe])//mirrored on y axis, hence safety offset already included
    mirror([1,0,0])
    fluegel();
//     
    translate([-hakenrotationradius/2,spurweite,fahrbahnhoehe])
    mirror([0,1,0])
    fluegel();
//    
    translate([laenge-hakenrotationradius/2,spurweite,fahrbahnhoehe])
    mirror([1,0,0])
    mirror([0,1,0])
    fluegel();
}

module schiene(laenge, radius=gleisdicke/2){
    stange(laenge,radius=radius);
    color("red")
    haken(xoffset=laenge,knob=false);
    rotatehaken(xoffset=0, knob=false);
}

module stange(laenge,radius=gleisdicke/2){
    rotate([0,90,0])
    cylinder(r=radius, h=laenge, $fn=fn);     
}



 
module drehschwelle(spurweite=spurweite,winkel=120,scope=1){ 
    if (scope==1){
        skip = 40; 
        limit = winkel/skip-1;
        echo(limit);
        for (i = [0:limit]){
            translate([-scope*11.9-spurweite/2,0,6]) 
            rotate([0,0,skip*i+skip/4])           
            difference() {
//                outer cylinder
                rotate_extrude(convexity = 10, angle=skip/2, $fn=fn)
                translate([scope*17.5,0,0])
                circle(d=spurweite*1.15);
//                inner cylinder
                rotate([0,0,-.1])     //drop initial membrane      
                rotate_extrude(convexity = 10, angle=skip/2+1, $fn=fn)
                translate([scope*17.5,0,0])
                circle(d=spurweite*.9);
    //                rather radical crop for schwellen
                translate([0,0,fahrbahnhoehe/2-4])
                cylinder(d=scope*sechseckkantenlaenge*2,h=8);
            }
        }
    }
    if (scope==3){//needs computation instead of guesswork 
        skip = 20; 
        limit = winkel/skip-1;
        for (i = [0:limit]){
//            translate([-scope*16-spurweite/2,0,3])
//            rotate([0,0,skip*i+skip/4])
//            rotate_extrude(convexity = 10, angle=skip/2, $fn=fn)
//            translate([scope*16,0,0])
//            square([spurweite,1]);             
            translate([-scope*15.8-spurweite/2,0,6]) 
            rotate([0,0,skip*i+skip/4])           
            difference() {
//                outer cylinder
                rotate_extrude(convexity = 10, angle=skip/2, $fn=fn)
                translate([scope*17.5,0,0])
                circle(d=spurweite*1.15);
//                inner cylinder
                rotate([0,0,-.1])     //drop initial membrane      
                rotate_extrude(convexity = 10, angle=skip/2+1, $fn=fn)
                translate([scope*17.5,0,0])
                circle(d=spurweite*.9);
    //                rather radical crop for schwellen
                translate([0,0,fahrbahnhoehe/2-4])
                cylinder(d=scope*sechseckkantenlaenge*2,h=8);
            }            
        }
    }
}

    

module haken(xoffset=0, knob=true){   
    translate([xoffset,0,-hakenrotationradius])
    rotate([90,270+rotationangle,0])
    rotate_extrude(convexity = 10, angle=rotationangle, $fn=fn)
    translate([hakenrotationradius, 0, 0])
    circle(r = gleisdicke/2, $fn=fn); 
    if(knob){
        translate([hakenrotationradius-0.5, 0, (-fahrbahnhoehe+2)])
        cylinder(r = 1.2*gleisdicke/2,h=1.1,$fn=fn);
    }
}

module rotatehaken(xoffset=0,knob=false){
    translate([xoffset,0,0])
    mirror([1,0,0]){
        haken(knob=knob);
    }
}

module fluegel(){
    color("blue")
    translate([schwellensafety,-1,0])
    rotate([45,0,0])    
//    cube([fluegelbreite,fluegelhoehe,1]); 
    prism(10,1,6,extraw=3);
}


module scheibe(){ 
    circle(d=gleisdicke);
}


module doppelscheibe(abstand=spurweite){
    translate([-abstand/2,0,0])
    scheibe();
    translate([abstand/2,0,0])
    scheibe();
}
 
module kurve(winkel=120,scope=1){
    drehschwelle(spurweite=spurweite,winkel=winkel,scope=scope);
//    rotate([0,0,30])
//    translate([scope*.5*5,scope*.5*20])
//    translate([spurweite/2,0])
//    rotate([0,0,90])
//    schwelle(); 
//    translate([spurweite/2,0])
//    rotate([0,0,90])
//    schwelle();
//    haken
    rotate([0,0,270])
    translate([0,.5*spurweite,fahrbahnhoehe])
    haken();
    rotate([0,0,270])
    translate([0,-.5*spurweite,fahrbahnhoehe])
    haken();
    translate([-scope*0.5*sechseckkantenlaenge, 0])
    rotate_extrude(convexity = 10, angle=winkel, $fn=fn)
    translate([scope*.5*sechseckkantenlaenge, fahrbahnhoehe])
    doppelscheibe();
//    translate([-schwellenbreite/2,0]) 

}

module loecher(angle=0){     
    translate([-spurweite/2,sechseckhoehe/2-hakenrotationradius,fahrbahnhoehe])
    linear_extrude(height=plaettchenhoehe)
    circle(d=3,$fn=20);
//    translate([-spurweite/2-1.5,sechseckhoehe/2-hakenrotationradius+1,0])    
//    rotate([0,0,0])
//    square([3,3.5]);
    
    translate([+spurweite/2,sechseckhoehe/2-hakenrotationradius,fahrbahnhoehe])
    linear_extrude(height=plaettchenhoehe)
    circle(d=3,$fn=20); 
//    translate([spurweite/2-1.5,sechseckhoehe/2-hakenrotationradius+1,0])    
//    rotate([0,0,0])
//    square([3,3.5]);
    
}module hakenfill(angle=0){          
    rotate([0,0,30]) 
    translate([sechseckhoehe/2,spurweite/2,fahrbahnhoehe])
    rotate([0,0,180])
    color("red")
    haken();
    rotate([0,0,30]) 
    translate([sechseckhoehe/2,-spurweite/2,fahrbahnhoehe])
    rotate([0,0,180])    
    color("red")
    haken();
}

module canal(){ 
    translate([-spurweite/2,sechseckhoehe/2,fahrbahnhoehe])  
    rotate ([90,0,0]) cylinder (h = 12, r=1.5, center = true, $fn=10);
    translate([-spurweite/2,sechseckhoehe/2-hakenrotationradius,0])  
    rotate ([0,0,0]) cylinder (h = 8, r=1.5, center = true, $fn=10);
    
    translate([+spurweite/2,sechseckhoehe/2,fahrbahnhoehe])  
    rotate ([90,0,0]) cylinder (h = 12, r=1.5, center = true, $fn=10);
    translate([+spurweite/2,sechseckhoehe/2-hakenrotationradius,0])  
    rotate ([0,0,0]) cylinder (h = 8, r=1.5, center = true, $fn=10);
      
}

module canals(){
    for(i=[0:5]){
        rotate([0,0,60*i]) 
        canal();
    }    
}

module runways(geometry=false,rotate=0){
    if (geometry=="*"){
        for(i=[0:2]){
            rotate([0,0,60*i+3])   
            rotate ([-90,0,0]) cylinder (h = sechseckhoehe+1, d=fahrbahnbreite, center = true, $fn=20);
        }    
    }    
    if (geometry=="I"){   
        rotate([0,0,rotate])
        rotate ([-90,0,0]) cylinder (h = sechseckhoehe+1, d=fahrbahnbreite, center = true, $fn=20); 
    }
    if (geometry=="X"){   
        rotate([0,0,rotate])
        rotate ([-90,0,0]) cylinder (h = sechseckhoehe+1, d=fahrbahnbreite, center = true, $fn=20); 
        rotate([0,0,rotate+60])
        rotate ([-90,0,0]) cylinder (h = sechseckhoehe+1, d=fahrbahnbreite, center = true, $fn=20); 
    }
    if (geometry=="c"){  
        rotate([0,0,rotate])
        translate([-1*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=120, $fn=fn)
        translate([1*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);
    }
    if (geometry=="ccc"){  
        rotate([0,0,rotate])
        translate([-1*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=120, $fn=fn)
        translate([1*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);
        rotate([0,0,120+rotate])
        translate([-1*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=120, $fn=fn)
        translate([1*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);
        rotate([0,0,240+rotate])
        translate([-1*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=120, $fn=fn)
        translate([1*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);
    }
    if (geometry=="C"){  
        rotate([0,0,rotate])
        translate([-3*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=61, $fn=fn)
        translate([3*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);
    }
    if (geometry=="cC"){  
        rotate([0,0,rotate])
        translate([-1*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=120, $fn=fn)
        translate([1*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);
        rotate([0,0,rotate+240])
        translate([-3*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=61, $fn=fn)
        translate([3*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);        
    }
    if (geometry=="Cc"){  
        rotate([0,0,rotate])
        translate([-3*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=61, $fn=fn)
        translate([3*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);   
        rotate([0,0,rotate+180])
        translate([-1*0.5*sechseckkantenlaenge, -sechseckhoehe/2-1,-fahrbahnbreite/2+fahrbahnhoehe])
        rotate_extrude(convexity = 10, angle=120, $fn=fn)
        translate([1*.5*sechseckkantenlaenge, fahrbahnhoehe])
        circle(d=fahrbahnbreite);     
    }
}

module lochset(){
    for(i=[0:5]){
        rotate([0,0,60*i]) 
        loecher();
    }
}

module hakenfillset(positionen=[0,1,2,3,4,5]){
    for(i=positionen){
        rotate([0,0,60*i]) 
        hakenfill();
    }
}

module plaettchen(hex_x=0,
        hex_y=0, 
        color="orange",
        kantenlaenge=sechseckkantenlaenge,
        hakenpositionen=[],
        geometry=false,
        runwayrotate=0
        ){     
//    color(color,0.6)    
    x_offset=hex_x*1.5*sechseckkantenlaenge;
    y_offset=hex_x*0.5*sechseckhoehe+hex_y*sechseckhoehe;
    color([cos((hex_x+1)*122)/2+0.5,
            cos((hex_y+1)*104)/2+0.5,
            cos((hex_x+hex_y+1)*133)/2+0.5],0.8)     
//add holes    
//    difference() {
//        translate([x_offset,y_offset,0])
//        linear_extrude(height=plaettchenhoehe)
//        circle($fn=6,r=sechseckkantenlaenge);
//        translate([x_offset,y_offset,0])
//        canals();    
//        translate([x_offset,y_offset,fahrbahnhoehe+spurweite/2])
//        runways(geometry=geometry,rotate=runwayrotate);
//    } 
    runways();    
//    add haken
    translate([x_offset,y_offset])
    hakenfillset(positionen=hakenpositionen);  
//    label plaettchen
    translate([x_offset-5,y_offset,plaettchenhoehe])
    text(str(hex_x));
    translate([x_offset+5,y_offset,plaettchenhoehe])
    text(str(hex_y));    
}



  
//rotate
module schwelle(spurweite=spurweite){   
   translate([0,0,gleisdicke*1.5])      
    rotate([90,0,90])
    difference() { 
                translate([0.5*spurweite,0,0])
//                rotate([90,0,0])
                cylinder(d=1.15*spurweite,h=schwellenbreite);
                translate([0.5*spurweite,0,-1])
//                rotate([90,0,0])
                cylinder(d=.95*spurweite,h=schwellenbreite+2);
                translate([-0.5*spurweite,-2.8,-.8*spurweite])
//                rotate([90,0,0])
                cube(spurweite*2);               
            }
}

module schwelleold(spurweite=spurweite){
    translate([0,0,gleisdicke/48])
    color("green")
    rotate([-90,0,0])
    cube([schwellenbreite,1,spurweite]);     
}


// good

//plaettchen(-1,2,hakenpositionen=[0],geometry="Cc",runwayrotate=0);
//plaettchen(0,1,geometry="I");
//plaettchen(1,-2,geometry="ccc",runwayrotate=240);
//plaettchen(1,1,hakenpositionen=[5],geometry="C",runwayrotate=180);
//plaettchen(2,-1,geometry="cC",runwayrotate=180);
//plaettchen(4,-1,geometry="X",runwayrotate=120);
//
//translate([132,10,0]) 
//rotate([0,0,30])
gleis(sechseckhoehe,spurweite,extra_schwellen=0);
  

 
//enge kurve
//translate([0,sechseckhoehe*1.5])
//kurve(120); 
//

//weite kurve
//translate([sechseckkantenlaenge*3,sechseckhoehe/2])
//kurve(60,scope=3); 
//
////U-turn
//translate([sechseckkantenlaenge*1.5,2*sechseckhoehe])
//kurve(180,scope=3); 
// 
//
////S-Kurve
//translate([sechseckkantenlaenge*1.5,-sechseckhoehe])
//kurve(60,scope=3); 
//rotate([0,0,180])
//translate([0,-sechseckhoehe/2])
//kurve(60,scope=3); 
//










































 


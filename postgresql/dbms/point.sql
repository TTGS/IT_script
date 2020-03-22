--点类型 
select '(1,2)'::point  
select point'(1,2)'
select point(21,22) 

--抽取坐标点
select ('(1,2)'::point)[0]  
select ('(1,2)'::point)[1]  


--平面坐标系中两点距离
select point'(1,2)' <-> point(1,22) 
 
select point_distance(	 point '(9,0)', point '(0,0)'  ) 
point_distance
--------------
             9

--平面坐标系中，点到0+点到0的长度平移新坐标点
select point'(1,1)' + point(2,2)
select point(3,3) - point'(1.2,1.2)' 

select point(-6,8)*point(3,4) 
select point(6,8)*point(3,4) 


select point(-14.0,48.0)<->point(6,8), (point(-14.0,48.0)<->point(6,8))^2 ,
point(-14.0,48.0)<->point(3,4) ,( point(-14.0,48.0)<->point(3,4) )^2,
point(6,8)<->point(3,4) ,( point(6,8)<->point(3,4))^2 

--点是否平行
select point(6,8) ?-  point(7,8),point(6,8) ?-  point(6,7) ; 
--点是否垂直
select point(6,8) ?|  point(7,8),point(6,8) ?|  point(6,7) ; 

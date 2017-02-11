set @row=0;
delete from oc_product;
insert into oc_product
(product_id,model,sku,upc,ean,
jan,isbn,mpn,location,quantity,
stock_status_id,image,manufacturer_id,shipping,price,
points,tax_class_id,date_available,weight,weight_class_id,
length,width,height,length_class_id,subtract,
minimum,sort_order,status,viewed,date_added,date_modified)
select p.id,p.title,0,0,0,
0,0,0,0,999,
7,concat('catalog/product/',SUBSTRING_INDEX(pi.link, "/", -1)),0,1,100.0,
0,9,'2016-12-01',0,2,
ifnull(d1.value,0),ifnull(split_string(d3.value,'-',1),0),ifnull(split_string(d2.value,' - ',1),0),1,1,
1,(@row:=@row+1),1,0,now(),now()
from product p
left join product_image pi on pi.product=p.id
left join dimension d1 on d1.product=p.id and d1.dimension=1
left join dimension d2 on d2.product=p.id and d2.dimension=2
left join dimension d3 on d3.product=p.id and d3.dimension=3;

delete from oc_product_to_layout;
insert into oc_product_to_layout (product_id,store_id,layout_id)
select p.id,0,2
from product p;

insert into oc_product_to_category (product_id,category_id)
select p.id,p.line+100
from product p;

insert into oc_product_to_store (product_id,store_id)
select product_id,0
from oc_product;

insert into oc_product_description (product_id,language_id,name,description,tag,meta_title,meta_description,meta_keyword)
select id,2,title,dop,name,title,dop,''
from product;

set @row=0;
insert into oc_category
(category_id,image,parent_id,top,`column`,sort_order,status,date_added,date_modified)
select c.id,replace(ci.link,'https://b2b.nowystyl.ua/media/',''),ifnull(c.parent,0),if(c.parent IS NULL,1,0),1,c.id,1,now(),now()
from category c
left join category_image ci on ci.category=c.id and ci.level=0;

insert into oc_category (category_id,image,parent_id,top,`column`,sort_order,status,date_added,date_modified)
select l.id+100,replace(li.link,'https://b2b.nowystyl.ua/media/',''),l.category,0,1,l.id+100,1,now(),now()
from line l
left join line_image li on li.line=l.id and li.level=0;

insert into oc_category_description (category_id,language_id,name,description,meta_title,meta_description,meta_keyword)
select c.id,2,c.title,ifnull(c.text,''),c.title,ifnull(c.text,''),''
from category c;

insert into oc_category_description (category_id,language_id,name,description,meta_title,meta_description,meta_keyword)
select l.id+100,2,l.title,ifnull(l.text,''),l.title,ifnull(l.text,''),''
from line l;

insert into oc_category_to_store (category_id,store_id)
select category_id,0
from oc_category;

insert into oc_category_path (category_id,path_id,level)
select category_id,category_id,0
from oc_category
where parent_id=0;

insert into oc_category_path (category_id,path_id,level)
select c1.category_id,c1.category_id,1
from oc_category c1
join oc_category c2 on c1.parent_id=c2.category_id and c2.parent_id=0
union
select c1.category_id,c2.category_id,0
from oc_category c1
join oc_category c2 on c1.parent_id=c2.category_id and c2.parent_id=0;

insert into oc_category_path (category_id,path_id,level)
select c1.category_id,c3.category_id,0
from oc_category c1
join oc_category c2 on c1.parent_id=c2.category_id
join oc_category c3 on c2.parent_id=c3.category_id
where c1.category_id>=100
union
select c1.category_id,c2.category_id,1
from oc_category c1
join oc_category c2 on c1.parent_id=c2.category_id
join oc_category c3 on c2.parent_id=c3.category_id
where c1.category_id>=100
union
select c1.category_id,c1.category_id,2
from oc_category c1
join oc_category c2 on c1.parent_id=c2.category_id
join oc_category c3 on c2.parent_id=c3.category_id
where c1.category_id>=100;

insert into oc_category_to_layout (category_id,store_id,layout_id)
select c1.category_id,0,0
from oc_category c1;

begin;
delete from `oc_category`;
delete from `oc_category_description`;
delete from `oc_category_path`;
delete from `oc_category_to_layout`;
delete from `oc_category_to_store`;
delete from `oc_product`;
delete from `oc_product_to_store`;
delete from `oc_product_description`;
delete from `oc_product_to_category`;
delete from `oc_product_to_layout`;
commit;

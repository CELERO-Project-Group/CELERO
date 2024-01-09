--
-- PostgreSQL database dump
--

-- Dumped from database version 11.22 (Debian 11.22-0+deb10u1)
-- Dumped by pg_dump version 11.22 (Debian 11.22-0+deb10u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO postgres;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO postgres;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: __gis_is_allcompany(character varying, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.__gis_is_allcompany(tg_op_f character varying, cmpny_id integer, cmpny_name character varying DEFAULT NULL::character varying, cmpny_address character varying DEFAULT NULL::character varying, cmpny_lat character varying DEFAULT NULL::character varying, cmpny_long character varying DEFAULT NULL::character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

DECLARE  

    var_qeom GEOMETRY DEFAULT NULL;  

    var_country_id int DEFAULT 0 ; 

 

BEGIN





	IF (tg_op_f = 'UPDATE') or  (tg_op_f = 'INSERT') THEN	  

	    IF length( cmpny_long) > 0 THEN 

		var_qeom =  ST_GeometryFromText('POINT (' || cmpny_long|| '   ' || cmpny_lat  || ')',4326) ;

		IF (ST_IsValid(var_qeom) ='f') THEN 

			RAISE NOTICE 'Nokta Koordinatlar─▒n da Bozukluk Var. ─░┼şlem Yap─▒lamad─▒.!! ';	

		END IF ;



		----------------

		var_country_id =  id from gis_world 

                    where ST_Intersects( geom,var_qeom ) ='t';



                update t_cmpny 

                set country_id = var_country_id

                where id = cmpny_id ;

                ---------------		

		DELETE FROM gis_all_company where company_id = cmpny_id;

		INSERT INTO gis_all_company(company_id, company_name, company_address, geom)

		VALUES ( cmpny_id, cmpny_name,cmpny_address,

			ST_GeometryFromText('POINT (' || cmpny_long|| ' ' || cmpny_lat || ')',4326));

		

		update gis_all_company 

                set country_id = var_country_id

                where company_id= cmpny_id;







		

	    END IF;

         END IF;



	IF (tg_op_f = 'DELETE') THEN	 	  

	    DELETE FROM gis_all_company WHERE company_id = cmpny_id;	    	 	 

	END IF;

 

	 



     RETURN 0;





END;

$$;


ALTER FUNCTION public.__gis_is_allcompany(tg_op_f character varying, cmpny_id integer, cmpny_name character varying, cmpny_address character varying, cmpny_lat character varying, cmpny_long character varying) OWNER TO postgres;

--
-- Name: __is_scenario_delete(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.__is_scenario_delete(id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE

  

  l_id   INTEGER:=id;

BEGIN

	EXECUTE 'DELETE FROM "t_is_prj" WHERE id= $1;' 

					USING l_id ;

	EXECUTE 'DELETE FROM "t_is_prj_details" WHERE is_prj_id= $1;' 

					USING l_id ;

					

            RETURN 1;

        EXCEPTION WHEN others THEN

        --EXCEPTION

            -- Do nothing, and loop to try the UPDATE again.

		raise notice '% %', SQLERRM, SQLSTATE;

		--RAISE NOTICE 'exception at─▒ld─▒';

     RETURN 0;





END;

$_$;


ALTER FUNCTION public.__is_scenario_delete(id bigint) OWNER TO postgres;

--
-- Name: company_insert_for_is(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.company_insert_for_is() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$

DECLARE

    /*var_company_row RECORD;

    var_qeom GEOMETRY DEFAULT NULL;

    var_geom_old GEOMETRY DEFAULT NULL;*/

    var_company_id INTEGER;

    var_company_name_new VARCHAR(200);

    var_company_name_old VARCHAR(200);

BEGIN



	

	 IF (TG_OP = 'DELETE') THEN

	    var_company_id = OLD.id;

	    var_company_name_old = OLD.name;

	    RAISE NOTICE 'company  id % deleted company name % ', var_company_id, var_company_name_old;

	    DELETE FROM "t_flow_total_per_cmpny" WHERE cmpny_id = var_company_id;

	    EXECUTE 'DELETE FROM "t_flow_total_per_cmpny" 

				WHERE cmpny_id = $1;' 

					USING var_company_id ;

	    

	ELSIF(TG_OP = 'UPDATE') THEN

		var_company_id = NEW.id;

		var_company_name_new = NEW.name;

		var_company_name_old = OLD.name;





		IF(var_company_name_new::text<>var_company_name_old::text)  THEN

			RAISE NOTICE ' eski ve yeni firma isimleri ayn─▒ olmad─▒─ş─▒ i├ğin i┼şlem yap─▒lm─▒┼şt─▒r';

			

		ELSE

			RAISE NOTICE ' eski ve yeni firma isimleri ayn─▒ oldu─şu i├ğin i┼şlem yap─▒lmam─▒┼şt─▒r';

		END IF;



	ELSIF(TG_OP = 'INSERT') THEN

	    var_company_id = NEW.id;

	    var_company_name_new = NEW.name;

	    RAISE NOTICE 'company  id % inserted company name % inserted', var_company_id, var_company_name_new;

	    RAISE NOTICE 'INSERT INTO "t_flow_total_per_cmpny" (cmpny_id,cmpny_name)

					VALUES(%, %)', var_company_id, var_company_name_new;

	    EXECUTE 'INSERT INTO "t_flow_total_per_cmpny" (cmpny_id, cmpny_name)

					VALUES($1, $2)' 

					USING var_company_id, var_company_name_new ;



	END IF;



    RETURN NULL;

END;

$_$;


ALTER FUNCTION public.company_insert_for_is() OWNER TO postgres;

--
-- Name: gis_is_allcompany(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gis_is_allcompany() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE    

    var_qeom GEOMETRY DEFAULT NULL;   

    var_company_id INTEGER;

    var_company_name VARCHAR(150);

    var_company_address  VARCHAR(200);    

    var_latitude VARCHAR(25);

    var_longitude VARCHAR(25);

    var_latitude_old VARCHAR(25);

    var_longitude_old VARCHAR(25);

    var_qeom_old GEOMETRY DEFAULT NULL; 

    

BEGIN

   var_company_id = OLD.id;

   var_company_name = new.name;

   var_latitude= NEW.latitude;

   var_longitude= NEW.longitude;

   var_latitude_old= OLD.latitude;

   var_longitude_old= OLD.longitude;

   var_company_address = NEW.company_address;

   var_qeom_old = OLD.geom;

   var_qeom = NEW.geom;





     IF  ( ST_Equals( var_qeom,var_qeom_old) ='f' ) THEN

	IF (TG_OP = 'UPDATE')  or (TG_OP = 'INSERT')   THEN	  

		var_qeom = ST_Buffer(ST_GeometryFromText('POINT (' || t_cmpny.longitude|| '   ' || t_cmpny.latitude  || ')',4326),0.0001) ;

		IF ST_IsValid(var_qeom) ='f'  THEN 

			RAISE NOTICE 'Nokta Koordinatlar─▒n da Bozukluk Var. ─░┼şlem Yap─▒lamad─▒.!! ';	

		 

		END IF;

	END IF;

     END IF;



    





	 IF (TG_OP = 'DELETE') THEN	  

	    RAISE NOTICE 'company  id % deleted company name % ', var_company_id, var_company_name;

	    DELETE FROM gis_all_company WHERE company_id = var_company_id;	    

	 ELSIF(TG_OP = 'UPDATE') THEN   

	    IF  ( ST_Equals( var_qeom,var_qeom_old) ='f' ) THEN	

		var_qeom = ST_Buffer(ST_GeometryFromText('POINT (' || t_cmpny.longitude|| '   ' || t_cmpny.latitude  || ')',4326),0.0001) ;

		IF ST_IsValid(var_qeom) ='t'  THEN 

			update gis_all_company set geom = var_qeom , 

			company_name = var_company_name, company_address = var_company_address 

			where company_id = var_company_id ;	

		END IF;	 

		END IF;	 

	ELSIF(TG_OP = 'INSERT') THEN

	   IF  ( ST_Equals( var_qeom,var_qeom_old) ='f' ) THEN

		var_qeom = ST_Buffer(ST_GeometryFromText('POINT (' || t_cmpny.longitude|| '   ' || t_cmpny.latitude  || ')',4326),0.0001) ;

		IF ST_IsValid(var_qeom) ='t'  THEN 

			INSERT INTO gis_all_company(company_id, company_name, company_address, geom)  VALUES 

				(var_company_id, var_company_name,   var_company_address , var_qeom ) ; 

			

		END IF;

		END IF;	 

	END IF;

 

	 

	    

	



    RETURN NULL;

END;

$$;


ALTER FUNCTION public.gis_is_allcompany() OWNER TO postgres;

--
-- Name: gis_is_line_maker(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gis_is_line_maker() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$

DECLARE

    var_company_row RECORD;

    var_qeom GEOMETRY DEFAULT NULL;

    var_geom_old GEOMETRY DEFAULT NULL;

    var_to_company_id INTEGER;

    var_from_company_id INTEGER;

    var_from_company_id_old INTEGER;

    var_deleted_company_name VARCHAR(255);



    var_company_name_new VARCHAR(255);

    var_address_new VARCHAR(100);

    var_company_name_old VARCHAR(255);

    var_address_old VARCHAR(100);

 



---------------------------------

    var_latitude VARCHAR(25);

    var_longitude VARCHAR(25);

    var_country_id int;

    var_qeom_all GEOMETRY DEFAULT NULL;

    var_cmpny_id int ; 

    var_gis_company_control INTEGER;

---------------------------------

        

BEGIN



        IF (TG_OP = 'INSERT') THEN 

	var_qeom = NEW.geom;	

	var_company_name_new = NEW.name;

	var_address_new =NEW.address ; 

	var_from_company_id= NEW.id;  

	var_latitude= NEW.latitude;

	var_longitude= NEW.longitude;	

	END IF;   	



	IF (TG_OP = 'UPDATE') THEN 

	var_from_company_id= OLD.id;  

	var_company_name_old = OLD.name;

	var_address_old =OLD.address;

	var_geom_old = OLD.geom;

	var_cmpny_id = old.id;

	var_latitude= NEW.latitude;

	var_longitude= NEW.longitude;	

	END IF; 



	IF (TG_OP = 'DELETE')  THEN 

	var_cmpny_id = old.id;

	var_from_company_id_old = OLD.id;

	var_deleted_company_name = OLD.name;

	var_longitude = '';

	END IF; 



	var_country_id = 0 ; 

	var_gis_company_control = 0;



	IF length(trim(both ' ' from var_longitude)) > 0 THEN 

		var_qeom_all = (Select ST_GeometryFromText('POINT (' || var_longitude|| '   ' || var_latitude  || ')',4326)) ;  

		IF (ST_IsValid(var_qeom_all) = 't') THEN 

			var_country_id = (select COALESCE((SELECT COALESCE(id,0)  from gis_world where ST_Intersects( geom,var_qeom_all ) ='t'),0));

		END IF;

	END IF ;

	

	IF (TG_OP = 'UPDATE') or  (TG_OP = 'INSERT') THEN	  

	    IF length(trim(both ' ' from var_longitude)) > 0  THEN 	 

		IF (ST_IsValid(var_qeom_all) <>'t') THEN 

			RAISE NOTICE 'Nokta Koordinatlar─▒nda Bozukluk Var. ─░┼şlem Yap─▒lamad─▒.!! ';	

		END IF ;

		IF (ST_IsValid(var_qeom_all) ='t') THEN 

		

                /* 1 -----------------*/	

			IF (var_country_id > 0) THEN

			--IF (var_qeom_all::text<>var_geom_old::text) THEN

				IF (TG_OP = 'INSERT') THEN						

					INSERT INTO gis_all_company(company_id, company_name, company_address, country_id, geom)

					VALUES ( var_cmpny_id, var_company_name_new,var_address_new,var_country_id, ST_Buffer(var_qeom_all,0.0001) );				 

				END IF;

			

				DELETE FROM gis_all_company_point where company_id =  var_cmpny_id;

				INSERT INTO gis_all_company_point(company_id, country_id,geom)

				VALUES ( var_cmpny_id, var_country_id, var_qeom_all );		

			

				DELETE FROM "GIS_IS_Predefined" WHERE from_company = var_from_company_id;

				DELETE FROM "GIS_IS_Predefined" WHERE to_company = var_from_company_id;

				insert into "GIS_IS_Predefined" (geom, from_company, to_company)

				SELECT     

					ST_MakeLine(ST_MakePoint( ST_X(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || c.longitude|| '   ' || c.latitude  || ')',4326))))),

					ST_Y(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || c.longitude|| '   ' || c.latitude  || ')',4326)))))),

					ST_MakePoint(ST_X(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || d.longitude|| '   ' || d.latitude  || ')',4326))))), 

					ST_Y(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || d.longitude|| '   ' || d.latitude  || ')',4326))) )) )   ),

					c.id  ,d.id  

				FROM   t_cmpny c

				inner join t_cmpny d on d.id <> c.id 

				where c.id = var_from_company_id;



				insert into   "GIS_IS_Predefined" (geom, from_company, to_company)

				SELECT     

					ST_MakeLine(ST_MakePoint( ST_X(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || c.longitude|| '   ' || c.latitude  || ')',4326))))),

					ST_Y(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || c.longitude|| '   ' || c.latitude  || ')',4326)))))),

					ST_MakePoint(ST_X(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || d.longitude|| '   ' || d.latitude  || ')',4326))))), 

					ST_Y(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || d.longitude|| '   ' || d.latitude  || ')',4326))) )) )   ),

					c.id  ,d.id  

				FROM   t_cmpny c

				inner join t_cmpny d on d.id <> c.id 

				where d.id = var_from_company_id;	







------------------------------------------------------------------ gis_is_predefined_project kay─▒tlar─▒n─▒n guncellenmesi

				update gis_is_predefined_project   

				set geom =   "GIS_IS_Predefined".geom

				from "GIS_IS_Predefined"   

				where  "GIS_IS_Predefined".from_company = gis_is_predefined_project.from_company  and "GIS_IS_Predefined".to_company  = gis_is_predefined_project.to_company

				and "GIS_IS_Predefined".from_company = var_from_company_id; 





				update gis_is_predefined_project   

				set geom =   "GIS_IS_Predefined".geom

				from "GIS_IS_Predefined"   

				where  "GIS_IS_Predefined".from_company = gis_is_predefined_project.from_company  and "GIS_IS_Predefined".to_company  = gis_is_predefined_project.to_company

				and "GIS_IS_Predefined".to_company = var_from_company_id ;



------------------------------------------------------------------

				



		/*----------------- 1 */		



			--ELSE

			  --   RAISE NOTICE 'eski ve yeni geom bilgileri e┼şit oldu─şu i├ğin i┼şlem yap─▒lama─▒┼şt─▒r';

			--END IF;			

		END IF;	

		/* --1 

		Bu k─▒s─▒m daha sonra de─şi┼şecek. firma geometry si uzerinden orta noktan─▒n yarat─▒lmas─▒  gerekli 	

		Firma geometry sininde kaydedildigi yer  buras─▒  de─şil. 

                */		

                END IF;

	     END IF;

         END IF;       



	IF (TG_OP = 'DELETE') THEN

	    RAISE NOTICE 'company  id % deleted company name % ', var_from_company_id_old, var_deleted_company_name;

	    DELETE FROM "GIS_IS_Predefined" WHERE from_company = var_from_company_id_old;

	    DELETE FROM gis_all_company_point where company_id = var_from_company_id_old;

	    DELETE FROM gis_all_company where company_id = var_from_company_id_old;	

	    DELETE FROM gis_is_predefined_project where  from_company   = var_from_company_id_old; 

	    DELETE FROM gis_is_predefined_project where  to_company   = var_from_company_id_old; 

         END IF ;

/*	    

	IF (TG_OP = 'UPDATE') or (TG_OP = 'INSERT') THEN	

	  IF (var_country_id > 0) THEN	

		IF ST_IsValid(var_qeom_all) ='t'  THEN 

			IF (var_qeom_all::text<>var_geom_old::text) THEN

			     DELETE FROM "GIS_IS_Predefined" WHERE from_company = var_from_company_id;



			     insert into   "GIS_IS_Predefined" (geom, from_company, to_company)

			     SELECT     

				ST_MakeLine(ST_MakePoint( ST_X(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || c.longitude|| '   ' || c.latitude  || ')',4326))))),

				ST_Y(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || c.longitude|| '   ' || c.latitude  || ')',4326)))))),

				ST_MakePoint(ST_X(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || d.longitude|| '   ' || d.latitude  || ')',4326))))), 

				ST_Y(ST_AsText(ST_Centroid((Select ST_GeometryFromText('POINT (' || d.longitude|| '   ' || d.latitude  || ')',4326))) )) )   ),

				c.id  ,d.id  

			     FROM   t_cmpny c

			     inner join t_cmpny d on d.id <> c.id 

			     where c.id = var_from_company_id;







*/

			     

			/*     FOR var_company_row IN SELECT * FROM t_cmpny WHERE  --geom::text <>'' 

			                                                          --AND geom::text IS NOT NULL 

			                                                          length(trim(both ' ' from longitude)) > 0 

			                                                          AND id <> var_from_company_id ORDER BY id ASC  LOOP

			        RAISE NOTICE 'company id % ', var_company_row.name;

				--var_to_company_id = (SELECT id FROM "t_cmpny" WHERE name = var_company_row.company_name);

					var_to_company_id = var_company_row.id;

					EXECUTE 'INSERT INTO "GIS_IS_Predefined" (geom, from_company, to_company)

						VALUES(

						 ST_MakeLine(

							ST_MakePoint(

							 ST_X(ST_AsText(ST_Centroid($1) )  ),

							  ST_Y(ST_AsText(ST_Centroid($1) )  )

							 ),

							ST_MakePoint(

							 ST_X(ST_AsText(ST_Centroid($2) )  ),

							  ST_Y(ST_AsText(ST_Centroid($2) )  )

							 ) 

						 ) , $3, $4

							 

						)' 

						--USING var_qeom, var_company_row.geom, var_from_company_id, var_to_company_id ;

						USING var_qeom_all, ST_GeometryFromText('POINT (' || var_company_row.longitude|| '   ' || var_company_row.latitude  || ')',4326), var_from_company_id, var_to_company_id;

				END LOOP;		     

				*/

/*			ELSE

			     RAISE NOTICE 'eski ve yeni geom bilgileri e┼şit oldu─şu i├ğin i┼şlem yap─▒lama─▒┼şt─▒r';

		   END IF;

		END IF;

	 END IF;	

*/	 

	/*ELSIF(TG_OP = 'INSERT') THEN	

	    IF (var_country_id > 0) THEN	 

		IF ST_IsValid(var_qeom_all) = 't'  THEN 



			FOR var_company_row IN SELECT * FROM "t_cmpny" WHERE --geom::text <>'' 

			                                                     --AND geom::text IS NOT NULL 

			                                                     length(trim(both ' ' from var_longitude)) > 0 

			                                                     AND id <> var_from_company_id ORDER BY id ASC  LOOP



			RAISE NOTICE 'company  id % ', var_company_row.name;

			--var_to_company_id = (SELECT id FROM "t_cmpny" WHERE name = var_company_row.company_name);

				var_to_company_id = var_company_row.id;

				EXECUTE 'INSERT INTO "GIS_IS_Predefined" (geom, from_company, to_company)

					VALUES(

					 ST_MakeLine(

						ST_MakePoint(

						 ST_X(ST_AsText(ST_Centroid($1) )  ),

						  ST_Y(ST_AsText(ST_Centroid($1) )  )

						 ),

						ST_MakePoint(

						 ST_X(ST_AsText(ST_Centroid($2) )  ),

						  ST_Y(ST_AsText(ST_Centroid($2) )  )

						 ) 

					 ) , $3, $4

					 	 

					)' 

					--USING var_qeom, var_company_row.geom, var_from_company_id, var_to_company_id ;

					USING var_qeom_all, ST_GeometryFromText('POINT (' || var_company_row.longitude|| '   ' || var_company_row.latitude  || ')',4326) , var_from_company_id, var_to_company_id;

			END LOOP;

			ELSE

			RAISE NOTICE 'geom de─şeri bo┼ş yada null ';

		END IF;

	

	   END IF;

 	   ELSE

	   RAISE NOTICE '─░┼şaretlenen Yer Herhangi Bir ├£lke S─▒n─▒r─▒ ─░├ğinde De─şil. !! ';	

	*/ 	

	    

	-- END IF;



	



    RETURN NULL;

END;

$_$;


ALTER FUNCTION public.gis_is_line_maker() OWNER TO postgres;

--
-- Name: gis_is_line_maker123(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gis_is_line_maker123() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$

DECLARE

    var_company_row RECORD;

    var_qeom GEOMETRY DEFAULT NULL;

    var_geom_old GEOMETRY DEFAULT NULL;

    var_to_company_id INTEGER;

    var_from_company_id INTEGER;

    var_from_company_id_old INTEGER;

    var_deleted_company_name VARCHAR(255);



    var_company_name_new VARCHAR(255);

    var_address_new VARCHAR(100);

    var_company_name_old VARCHAR(255);

    var_address_old VARCHAR(100);

    

    

        

BEGIN





	var_qeom = NEW.geom;

	var_geom_old = OLD.geom;

	var_company_name_new = NEW.name;

	var_address_new =NEW.address ; 

	var_company_name_old = OLD.name;

	var_address_old =OLD.address;



	IF (ST_Equals(var_qeom,var_geom_old ) = 'f') or (TG_OP = 'DELETE') or 

           ( var_address_new <> var_address_old) or (var_company_name_new<>var_company_name_old)

	

	THEN

		EXECUTE PROCEDURE company_insert_for_is;

	END IF;





	 IF (TG_OP = 'DELETE') THEN	

	    var_from_company_id_old = OLD.id;

	    var_deleted_company_name = OLD.name;

	    RAISE NOTICE 'company  id % deleted company name % ', var_from_company_id_old, var_deleted_company_name;

	    DELETE FROM "GIS_IS_Predefined" WHERE from_company = var_from_company_id_old;

	    

	ELSIF(TG_OP = 'UPDATE') THEN	

		var_from_company_id= NEW.id;		

		IF ST_IsValid(var_qeom) ='t'  THEN 

			IF (var_qeom::text<>var_geom_old::text) THEN

			     DELETE FROM "GIS_IS_Predefined" WHERE from_company = var_from_company_id;

			     FOR var_company_row IN SELECT * FROM "t_cmpny" WHERE geom::text <>'' 

			                                                          AND geom::text IS NOT NULL 

			                                                          AND id <> var_from_company_id ORDER BY id ASC  LOOP

			        RAISE NOTICE 'company  id % ', var_company_row.name;

				--var_to_company_id = (SELECT id FROM "t_cmpny" WHERE name = var_company_row.company_name);

					var_to_company_id = var_company_row.id;

					EXECUTE 'INSERT INTO "GIS_IS_Predefined" (geom, from_company, to_company)

						VALUES(

						 ST_MakeLine(

							ST_MakePoint(

							 ST_X(ST_AsText(ST_Centroid($1) )  ),

							  ST_Y(ST_AsText(ST_Centroid($1) )  )

							 ),

							ST_MakePoint(

							 ST_X(ST_AsText(ST_Centroid($2) )  ),

							  ST_Y(ST_AsText(ST_Centroid($2) )  )

							 ) 

						 ) , $3, $4

							 

						)' 

						USING var_qeom, var_company_row.geom, var_from_company_id, var_to_company_id ;

				END LOOP;

			     

			ELSE

			     RAISE NOTICE 'eski ve yeni geom bilgileri e┼şit oldu─şu i├ğin i┼şlem yap─▒lama─▒┼şt─▒r';

			END IF;

		END IF;

	 	

	ELSIF(TG_OP = 'INSERT') THEN	 

	    var_from_company_id= NEW.id;    	    

		IF ST_IsValid(var_qeom) ='f'  THEN 



			FOR var_company_row IN SELECT * FROM "t_cmpny" WHERE geom::text <>'' 

			                                                     AND geom::text IS NOT NULL 

			                                                     AND id <> var_from_company_id ORDER BY id ASC  LOOP



			RAISE NOTICE 'company  id % ', var_company_row.name;

			--var_to_company_id = (SELECT id FROM "t_cmpny" WHERE name = var_company_row.company_name);

				var_to_company_id = var_company_row.id;

				EXECUTE 'INSERT INTO "GIS_IS_Predefined" (geom, from_company, to_company)

					VALUES(

					 ST_MakeLine(

						ST_MakePoint(

						 ST_X(ST_AsText(ST_Centroid($1) )  ),

						  ST_Y(ST_AsText(ST_Centroid($1) )  )

						 ),

						ST_MakePoint(

						 ST_X(ST_AsText(ST_Centroid($2) )  ),

						  ST_Y(ST_AsText(ST_Centroid($2) )  )

						 ) 

					 ) , $3, $4

					 	 

					)' 

					USING var_qeom, var_company_row.geom, var_from_company_id, var_to_company_id ;

			END LOOP;

			ELSE

			RAISE NOTICE 'geom de─şeri bo┼ş yada null ';

		END IF;

	

		

	    

	END IF;



    RETURN NULL;

END;

$_$;


ALTER FUNCTION public.gis_is_line_maker123() OWNER TO postgres;

--
-- Name: is_scenario_delete(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_scenario_delete(id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

DECLARE

 

   --l_siparis_iade_id   BIGINT;

BEGIN

	DELETE FROM zeynel;

            RETURN 1;

        EXCEPTION WHEN others THEN

        --EXCEPTION

            -- Do nothing, and loop to try the UPDATE again.

     RAISE NOTICE 'exception at─▒ld─▒';

     RETURN 0;





END;

$$;


ALTER FUNCTION public.is_scenario_delete(id bigint) OWNER TO postgres;

--
-- Name: json_object_set_key(json, text, anyelement); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.json_object_set_key(json json, key_to_set text, value_to_set anyelement) RETURNS json
    LANGUAGE sql IMMUTABLE STRICT
    AS $$

SELECT COALESCE(

  (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')

     FROM (SELECT *

             FROM json_each("json")

            WHERE "key" <> "key_to_set"

            UNION ALL

           SELECT "key_to_set", to_json("value_to_set")) AS "fields"),

  '{}'

)::json

$$;


ALTER FUNCTION public.json_object_set_key(json json, key_to_set text, value_to_set anyelement) OWNER TO postgres;

--
-- Name: json_object_update_key(json, text, anyelement); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.json_object_update_key(json json, key_to_set text, value_to_set anyelement) RETURNS json
    LANGUAGE sql IMMUTABLE STRICT
    AS $$

SELECT CASE

  WHEN ("json" -> "key_to_set") IS NULL THEN "json"

  ELSE COALESCE(

    (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')

       FROM (SELECT *

               FROM json_each("json")

              WHERE "key" <> "key_to_set"

              UNION ALL

             SELECT "key_to_set", to_json("value_to_set")) AS "fields"),

    '{}'

  )::json

END

$$;


ALTER FUNCTION public.json_object_update_key(json json, key_to_set text, value_to_set anyelement) OWNER TO postgres;

--
-- Name: t_cmpny_filler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_cmpny_filler() RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    var_company_row RECORD;

    var_qeom GEOMETRY DEFAULT NULL;

    var_geom_old GEOMETRY DEFAULT NULL;

    var_to_company_id INTEGER;

    var_from_company_id INTEGER;

    var_from_company_id_old INTEGER;

    var_deleted_company_name VARCHAR(100);

BEGIN



	FOR var_company_row IN SELECT * FROM "GIS_Kaucuk" ORDER BY id ASC  LOOP

	RAISE NOTICE 'company  id % ', var_company_row.company_name;

	UPDATE "t_cmpny" SET geom = var_company_row.geom WHERE name = var_company_row.company_name;

	END LOOP;



	FOR var_company_row IN SELECT * FROM "GIS_Medical" ORDER BY id ASC  LOOP

	RAISE NOTICE 'company  id % ', var_company_row.company_name;

	UPDATE "t_cmpny" SET geom = var_company_row.geom WHERE name = var_company_row.company_name;

	END LOOP;



	FOR var_company_row IN SELECT * FROM "GIS_Savunma" ORDER BY id ASC  LOOP

	RAISE NOTICE 'company  id % ', var_company_row.company_name;

	UPDATE "t_cmpny" SET geom = var_company_row.geom WHERE name = var_company_row.company_name;

	END LOOP;

	

	FOR var_company_row IN SELECT * FROM "GIS_company" ORDER BY id ASC  LOOP

	RAISE NOTICE 'company  id % ', var_company_row.company_name;

	UPDATE "t_cmpny" SET geom = var_company_row.geom WHERE name = var_company_row.company_name;

	END LOOP;



	FOR var_company_row IN SELECT * FROM "GIS_isim" ORDER BY id ASC  LOOP

	RAISE NOTICE 'company  id % ', var_company_row.company_name;

	UPDATE "t_cmpny" SET geom = var_company_row.geom WHERE name = var_company_row.company_name;

	END LOOP;



	FOR var_company_row IN SELECT * FROM "GIs_Arus" ORDER BY id ASC  LOOP

	RAISE NOTICE 'company  id % ', var_company_row.company_name;

	UPDATE "t_cmpny" SET geom = var_company_row.geom WHERE name = var_company_row.company_name;

	END LOOP;

			

    RETURN 1;

END;

$$;


ALTER FUNCTION public.t_cmpny_filler() OWNER TO postgres;

--
-- Name: test(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.test() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

    var_company_row RECORD;

    var_qeom GEOMETRY DEFAULT NULL;

    var_geom_old GEOMETRY DEFAULT NULL;

    var_to_company_id INTEGER;

    var_from_company_id INTEGER;

    var_from_company_id_old INTEGER;

    var_deleted_company_name VARCHAR(100);

BEGIN







    RETURN NULL;

END;

$$;


ALTER FUNCTION public.test() OWNER TO postgres;

--
-- Name: trigger_company_flow_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_company_flow_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    <<fn>>
    DECLARE
	--var_flow_name VARCHAR(500);
	var_flow_id BIGINT DEFAULT NULL;
	var_flow_id_old BIGINT DEFAULT NULL;
	var_cmpny_id BIGINT DEFAULT NULL;
	var_column_name VARCHAR(200) DEFAULT NULL;
	var_column_name_old VARCHAR(200) DEFAULT NULL;
	var_qntty NUMERIC(10,2) DEFAULT NULL;
	var_unit VARCHAR(50) DEFAULT NULL;
	var_quality VARCHAR(100) DEFAULT NULL;
	var_flow_type VARCHAR(50) DEFAULT NULL;
	var_index_name VARCHAR(220) DEFAULT NULL;
    BEGIN
    RETURN NULL;
    END;
$$;


ALTER FUNCTION public.trigger_company_flow_change() OWNER TO postgres;

--
-- Name: trigger_company_flow_insert_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_company_flow_insert_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    <<fn>>

    DECLARE

	--var_flow_name VARCHAR(500);

	var_flow_id BIGINT DEFAULT NULL;

	var_flow_id_old BIGINT DEFAULT NULL;

	var_cmpny_id BIGINT DEFAULT NULL;

	var_column_name VARCHAR(200) DEFAULT NULL;

	var_column_name_old VARCHAR(200) DEFAULT NULL;

	var_qntty NUMERIC(10,2) DEFAULT NULL;

	var_unit VARCHAR(50) DEFAULT NULL;

	var_quality VARCHAR(100) DEFAULT NULL;

	var_flow_type VARCHAR(50) DEFAULT NULL;

	var_index_name VARCHAR(220) DEFAULT NULL;

    BEGIN

        

        IF (TG_OP = 'DELETE') THEN

	    var_qntty= OLD.qntty;

        ELSE

            var_qntty= NEW.qntty;

        END IF;



	--IF (var_qntty::text <> '' OR var_qntty::text IS NOT NULL) THEN

	--IF (NEW.qntty IS NOT NULL) THEN

		IF (TG_OP = 'DELETE') THEN

		    var_flow_id:= OLD.flow_id;

		    var_cmpny_id:= OLD.cmpny_id;

		    var_column_name:= (SELECT name FROM t_flow WHERE id=var_flow_id);

		    

		    RAISE NOTICE 'DELETE flow id % ', var_flow_id;

		    RAISE NOTICE 'DELETE company id % ', var_cmpny_id;

		    RAISE NOTICE 'DELETE column name  % ', var_column_name;

		    EXECUTE 'UPDATE t_flow_total_per_cmpny SET "' || var_column_name  || '"= NULL ';



		    RETURN OLD;

		ELSIF (TG_OP = 'UPDATE') THEN

		    var_flow_id:= NEW.flow_id;

		    var_flow_id_old:= OLD.flow_id;

		    var_cmpny_id:= NEW.cmpny_id;

		    var_column_name:= (SELECT name FROM t_flow WHERE id=var_flow_id);

		    var_unit = (SELECT name FROM t_unit WHERE id=NEW.qntty_unit_id);

		    var_quality = NEW.quality;

		    var_qntty = NEW.qntty;

		    var_flow_type = (SELECT name FROM t_flow_type WHERE id=NEW.flow_type_id  AND active = 1);

		    

		    RAISE NOTICE 'UPDATE flow id % ', var_flow_id;

		    RAISE NOTICE 'UPDATE company id % ', var_cmpny_id;

		    RAISE NOTICE 'UPDATE column name  % ', var_column_name;

		    RAISE NOTICE 'INSERT quality  % ', var_quality;

		    RAISE NOTICE 'INSERT quantity  % ', var_qntty;

		    RAISE NOTICE 'UPDATE old flow id  % ', var_flow_id_old;



		    IF (var_flow_id_old::text <>var_flow_id::text) THEN

		    var_column_name_old:= (SELECT name FROM t_flow WHERE id=var_flow_id_old);

		    EXECUTE 'UPDATE t_flow_total_per_cmpny SET 

				"' || var_column_name_old  || '"= ''{ "column_name": "'|| COALESCE(var_column_name_old,'') ||'", "flow_properties": { "quantity": "0", "unit": "", "quality": "", "flow_type": "" } }''

						     WHERE cmpny_id='|| var_cmpny_id ||' ';

		     EXECUTE 'UPDATE t_flow_total_per_cmpny SET 

				"' || var_column_name  || '"= ''{ "column_name": "'|| COALESCE(var_column_name,'') ||'", "flow_properties": { "quantity": "'|| COALESCE(var_qntty,0) ||'", "unit": "'|| COALESCE(var_unit,'') ||'", "quality": "'|| COALESCE(var_quality,'')  ||'", "flow_type": "'|| COALESCE(var_flow_type,'') ||'" } }''

						     WHERE cmpny_id='|| var_cmpny_id ||' ';

		     ELSE

			EXECUTE 'UPDATE t_flow_total_per_cmpny SET 

				"' || var_column_name  || '"= ''{ "column_name": "'|| COALESCE(var_column_name,'') ||'", "flow_properties": { "quantity": "'|| COALESCE(var_qntty,0) ||'", "unit": "'|| COALESCE(var_unit,'') ||'", "quality": "'|| COALESCE(var_quality,'')  ||'", "flow_type": "'|| COALESCE(var_flow_type,'') ||'" } }''

						     WHERE cmpny_id='|| var_cmpny_id ||' ';

		     END IF;

		    RETURN NEW;

		ELSIF (TG_OP = 'INSERT') THEN

		    var_flow_id:= NEW.flow_id;

		    var_cmpny_id:= NEW.cmpny_id;

		    var_column_name:= (SELECT name FROM t_flow WHERE id=var_flow_id);

		    var_unit = (SELECT name FROM t_unit WHERE id=NEW.qntty_unit_id);

		    var_quality = NEW.quality;

		    var_flow_type = (SELECT name FROM t_flow_type WHERE id=NEW.flow_type_id  AND active = 1);

		    var_index_name:= var_column_name || '_index';



		    RAISE NOTICE 'INSERT flow id % ', var_flow_id;

		    RAISE NOTICE 'INSERT company id % ', var_cmpny_id;

		    RAISE NOTICE 'INSERT column name  % ', var_column_name;

		    RAISE NOTICE 'INSERT quality  % ', var_quality;

		    RAISE NOTICE 'INSERT quantity  % ', var_qntty;

		    

		    --EXECUTE 'INSERT INTO t_flow_total_per_cmpny (cmpny_id,'|| var_column_name ||' ) VALUES ('|| var_cmpny_id ||', ''{ "column_name": "' || var_column_name || '", "flow_properties": { "quantity": "'|| var_qntty ||'", "unit": "' || var_unit ||'", "quality": "' || var_quality ||'" } }'' )' ;

		    EXECUTE 'UPDATE t_flow_total_per_cmpny SET 

				"' || var_column_name  || '"= ''{ "column_name": "'|| COALESCE(var_column_name,'') ||'", "flow_properties": { "quantity": "'|| COALESCE(var_qntty,0) ||'", "unit": "'|| COALESCE(var_unit,'') ||'", "quality": "'|| COALESCE(var_quality,'')  ||'", "flow_type": "'|| COALESCE(var_flow_type,'') ||'" } }''

				WHERE cmpny_id='|| var_cmpny_id ||' ';

		         

			/*	IF NOT EXISTS (

				    SELECT 1

				    FROM   pg_class c

				    JOIN   pg_namespace n ON n.oid = c.relnamespace

				    WHERE  c.relname = LOWER(var_index_name)

				    AND    n.nspname = 'public' -- 'public' by default

				    ) THEN



				    --CREATE INDEX brass_index ON public.t_flow_total_per_cmpny((("Brass"->'flow_properties'->>'quantity')::numeric(10,2) ));

				  --  EXECUTE 'CREATE INDEX ' || LOWER(var_index_name) ||' ON public.t_flow_total_per_cmpny((("' || var_column_name ||'"->''flow_properties''->>''quantity'')::numeric(10,2) ));';



				ELSE 

				     RAISE NOTICE 'index bulundu';

			       END IF;

			       */

			

		    RETURN NEW;

		END IF;

	/*ELSE

		RAISE NOTICE 'qntty alan─▒ bo┼ş veya null de─şerindedir, qntty = %', var_qntty;

		RETURN NULL;

	END IF;*/

	RETURN NULL;



        --IF (select exists(select 1 from t_cmpny_flow where flow_id=var_flow_id AND cmpny_id = var_cmpny_id )) THEN

        /*IF (select exists(select 1 from t_flow_total_per_cmpny where  cmpny_id = var_cmpny_id ) AND 

		--(select column_name from information_schema.columns where table_name = 't_flow_total_per_company' AND table_schema = 'public' AND column_name = 

		--(SELECT 1  FROM t_flow_total_per_company  WHERE (SELECT name FROM t_flow WHERE id=var_flow_id) IS  NOT NULL)

		(SELECT EXISTS (SELECT * FROM t_flow_total_per_cmpny WHERE var_column_name <> '')	)

		)

	    THEN

	    RAISE NOTICE 'flow id % ve company id  % de─şerleri daha ├Ânceden t_cmpny_flow tablosuna girilmi┼ştir', var_flow_id, var_cmpny_id;

	ELSE

	    RAISE NOTICE 'flow id % ve company id  % de─şerleri daha ├Ânceden t_cmpny_flow tablosuna girilmemi┼ştir', var_flow_id, var_cmpny_id;

	END IF;*/

	

        RETURN NEW;

    END;

$$;


ALTER FUNCTION public.trigger_company_flow_insert_func() OWNER TO postgres;

--
-- Name: trigger_company_flow_insert_is_cahnge_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_company_flow_insert_is_cahnge_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    <<fn>>

    DECLARE

	--var_flow_name VARCHAR(500);

	var_flow_id BIGINT DEFAULT NULL;

	var_flow_id_old BIGINT DEFAULT NULL;

	var_cmpny_id BIGINT DEFAULT NULL;

	var_column_name VARCHAR(200) DEFAULT NULL;

	var_column_name_old VARCHAR(200) DEFAULT NULL;

	var_qntty NUMERIC(10,2) DEFAULT NULL;

	var_unit VARCHAR(50) DEFAULT NULL;

	var_quality VARCHAR(100) DEFAULT NULL;

	var_flow_type VARCHAR(50) DEFAULT NULL;

	var_index_name VARCHAR(220) DEFAULT NULL;

    BEGIN

        

        IF (TG_OP = 'DELETE') THEN

	    var_qntty= OLD.qntty;

        ELSE

            var_qntty= NEW.qntty;

        END IF;



	--IF (var_qntty::text <> '' OR var_qntty::text IS NOT NULL) THEN

	--IF (NEW.qntty IS NOT NULL) THEN

		IF (TG_OP = 'DELETE') THEN

		    /*var_flow_id:= OLD.flow_id;

		    var_cmpny_id:= OLD.cmpny_id;

		    var_column_name:= (SELECT name FROM t_flow WHERE id=var_flow_id);*/

		    

		    RAISE NOTICE 'DELETE flow id % ', var_flow_id;

		    RAISE NOTICE 'DELETE company id % ', var_cmpny_id;

		    RAISE NOTICE 'DELETE column name  % ', var_column_name;

		    EXECUTE 'UPDATE t_flow_total_per_cmpny SET "' || var_column_name  || '"= NULL ';



		    RETURN OLD;

		ELSIF (TG_OP = 'UPDATE') THEN

		    var_flow_id:= NEW.flow_id;

		    var_flow_id_old:= OLD.flow_id;

		    var_cmpny_id:= NEW.cmpny_id;

		    var_column_name:= (SELECT name FROM t_flow WHERE id=var_flow_id);

		    var_unit = (SELECT name FROM t_unit WHERE id=NEW.qntty_unit_id);

		    var_quality = NEW.quality;

		    var_qntty = NEW.qntty;

		    var_flow_type = (SELECT name FROM t_flow_type WHERE id=NEW.flow_type_id  AND active = 1);

		    

		    RAISE NOTICE 'UPDATE flow id % ', var_flow_id;

		    RAISE NOTICE 'UPDATE company id % ', var_cmpny_id;

		    RAISE NOTICE 'UPDATE column name  % ', var_column_name;

		    RAISE NOTICE 'INSERT quality  % ', var_quality;

		    RAISE NOTICE 'INSERT quantity  % ', var_qntty;

		    RAISE NOTICE 'UPDATE old flow id  % ', var_flow_id_old;





		    EXECUTE 'UPDATE t_is_prj_details SET 

				"from_quantity"= '|| COALESCE(var_flow_id,'') || '

						     WHERE cmpny_from_id='|| var_cmpny_id ||' ';

		     EXECUTE 'UPDATE t_is_prj_details SET 

				"to_quantity"= '|| COALESCE(var_flow_id,'') ||'

						     WHERE cmpny_to_id='|| var_cmpny_id ||' ';

		    

		     

		    RETURN NEW;

		ELSIF (TG_OP = 'INSERT') THEN

		    var_flow_id:= NEW.flow_id;

		    var_cmpny_id:= NEW.cmpny_id;

		    var_column_name:= (SELECT name FROM t_flow WHERE id=var_flow_id);

		    var_unit = (SELECT name FROM t_unit WHERE id=NEW.qntty_unit_id);

		    var_quality = NEW.quality;

		    var_flow_type = (SELECT name FROM t_flow_type WHERE id=NEW.flow_type_id  AND active = 1);

		    var_index_name:= var_column_name || '_index';



		    RAISE NOTICE 'INSERT flow id % ', var_flow_id;

		    RAISE NOTICE 'INSERT company id % ', var_cmpny_id;

		    RAISE NOTICE 'INSERT column name  % ', var_column_name;

		    RAISE NOTICE 'INSERT quality  % ', var_quality;

		    RAISE NOTICE 'INSERT quantity  % ', var_qntty;

		    

		    

			

		    RETURN NEW;

		END IF;

	/*ELSE

		RAISE NOTICE 'qntty alan─▒ bo┼ş veya null de─şerindedir, qntty = %', var_qntty;

		RETURN NULL;

	END IF;*/

	RETURN NULL;



        --IF (select exists(select 1 from t_cmpny_flow where flow_id=var_flow_id AND cmpny_id = var_cmpny_id )) THEN

        /*IF (select exists(select 1 from t_flow_total_per_cmpny where  cmpny_id = var_cmpny_id ) AND 

		--(select column_name from information_schema.columns where table_name = 't_flow_total_per_company' AND table_schema = 'public' AND column_name = 

		--(SELECT 1  FROM t_flow_total_per_company  WHERE (SELECT name FROM t_flow WHERE id=var_flow_id) IS  NOT NULL)

		(SELECT EXISTS (SELECT * FROM t_flow_total_per_cmpny WHERE var_column_name <> '')	)

		)

	    THEN

	    RAISE NOTICE 'flow id % ve company id  % de─şerleri daha ├Ânceden t_cmpny_flow tablosuna girilmi┼ştir', var_flow_id, var_cmpny_id;

	ELSE

	    RAISE NOTICE 'flow id % ve company id  % de─şerleri daha ├Ânceden t_cmpny_flow tablosuna girilmemi┼ştir', var_flow_id, var_cmpny_id;

	END IF;*/

	

        RETURN NEW;

    END;

$$;


ALTER FUNCTION public.trigger_company_flow_insert_is_cahnge_func() OWNER TO postgres;

--
-- Name: trigger_flow_insert_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_flow_insert_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    <<fn>>

    DECLARE

	var_flow_name VARCHAR(500);

	var_old_flow_name VARCHAR(500);

    BEGIN

	--RAISE NOTICE 'TG_OP name ->> %', TG_OP;

	IF (TG_OP = 'DELETE') THEN

		var_flow_name:= OLD.name;

		RAISE NOTICE 'DELETE column name ->> %', var_flow_name;

		EXECUTE 'ALTER TABLE t_flow_total_per_cmpny DROP COLUMN "' || var_flow_name || '" ; ';

		RETURN OLD;

	ELSIF (TG_OP = 'UPDATE') THEN 

		IF (SELECT EXISTS (SELECT column_name 

				FROM information_schema.columns 

				WHERE table_name='t_flow_total_per_cmpny' and column_name=NEW.name))

			

		    THEN

		    RAISE NOTICE 'bu column-> % daha ├Ânce ilgili tabloya girilmi┼ştir', NEW.name;

		ELSE

		    var_flow_name:= NEW.name;

		    var_old_flow_name:= OLD.name;

		    EXECUTE 'ALTER TABLE t_flow_total_per_cmpny RENAME COLUMN "' || var_old_flow_name || '"  TO "' || var_flow_name || '" ; ';

		END IF;

		RETURN NEW;

	ELSIF (TG_OP = 'INSERT') THEN

		var_flow_name:= NEW.name;

		EXECUTE 'ALTER TABLE t_flow_total_per_cmpny ADD COLUMN "' || var_flow_name || '"  json  NULL; ';

		RETURN NEW;

	END IF;

        

    END;

$$;


ALTER FUNCTION public.trigger_flow_insert_func() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: industrial_zones_clusters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industrial_zones_clusters (
    id bigint NOT NULL,
    industrial_zone_id integer DEFAULT 0 NOT NULL,
    cluster_name character varying(300)
);


ALTER TABLE public.industrial_zones_clusters OWNER TO postgres;

--
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clusters_id_seq OWNER TO postgres;

--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clusters_id_seq OWNED BY public.industrial_zones_clusters.id;


--
-- Name: es_definition_of_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.es_definition_of_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.es_definition_of_type_id_seq OWNER TO postgres;

--
-- Name: es_definition_of_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.es_definition_of_type (
    id integer DEFAULT nextval('public.es_definition_of_type_id_seq'::regclass) NOT NULL,
    project_id integer DEFAULT 0,
    type_id integer DEFAULT 0,
    type_detail_id integer DEFAULT 0,
    description_eng character varying(255),
    active integer DEFAULT 1,
    description_tr character varying(255)
);


ALTER TABLE public.es_definition_of_type OWNER TO postgres;

--
-- Name: es_project_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.es_project_settings (
    id integer NOT NULL,
    op_project_id integer NOT NULL,
    project_name character varying(255),
    report_server character varying(255),
    report_path character varying(255),
    report_image_road character varying(255),
    geoserver_road character varying(255),
    geoserver_wms character varying(255),
    geoserver_wfs character varying(255)
);


ALTER TABLE public.es_project_settings OWNER TO postgres;

--
-- Name: industrial_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industrial_zones (
    id bigint NOT NULL,
    name character varying(300)
);


ALTER TABLE public.industrial_zones OWNER TO postgres;

--
-- Name: industrial_zones_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industrial_zones_department_id_seq
    START WITH 6
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.industrial_zones_department_id_seq OWNER TO postgres;

--
-- Name: industrial_zones_departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industrial_zones_departments_id_seq
    START WITH 6
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.industrial_zones_departments_id_seq OWNER TO postgres;

--
-- Name: industrial_zones_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industrial_zones_departments (
    id integer DEFAULT nextval('public.industrial_zones_departments_id_seq'::regclass) NOT NULL,
    name character varying(250)
);


ALTER TABLE public.industrial_zones_departments OWNER TO postgres;

--
-- Name: industrial_zones_employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industrial_zones_employee (
    id bigint NOT NULL,
    industrial_zone_id integer DEFAULT 0 NOT NULL,
    cluster_id integer DEFAULT 0 NOT NULL,
    role_id integer DEFAULT 0 NOT NULL,
    employee_name character varying(200)
);


ALTER TABLE public.industrial_zones_employee OWNER TO postgres;

--
-- Name: industrial_zones_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industrial_zones_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.industrial_zones_employee_id_seq OWNER TO postgres;

--
-- Name: industrial_zones_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industrial_zones_employee_id_seq OWNED BY public.industrial_zones_employee.id;


--
-- Name: industrial_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industrial_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.industrial_zones_id_seq OWNER TO postgres;

--
-- Name: industrial_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industrial_zones_id_seq OWNED BY public.industrial_zones.id;


--
-- Name: industrial_zones_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industrial_zones_role (
    id integer,
    name character varying(250)
);


ALTER TABLE public.industrial_zones_role OWNER TO postgres;

--
-- Name: pk_all_company_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_all_company_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_all_company_id_sequence OWNER TO postgres;

--
-- Name: pk_all_company_point_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_all_company_point_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9223372036854775
    CACHE 1;


ALTER TABLE public.pk_all_company_point_id_sequence OWNER TO postgres;

--
-- Name: pk_company_arus_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_arus_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_arus_sequence OWNER TO postgres;

--
-- Name: pk_company_energy_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_energy_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_energy_sequence OWNER TO postgres;

--
-- Name: pk_company_isim_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_isim_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_isim_sequence OWNER TO postgres;

--
-- Name: pk_company_kaucuk_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_kaucuk_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_kaucuk_sequence OWNER TO postgres;

--
-- Name: pk_company_medical_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_medical_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_medical_sequence OWNER TO postgres;

--
-- Name: pk_company_savunma_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_savunma_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_savunma_sequence OWNER TO postgres;

--
-- Name: pk_company_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_company_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_company_sequence OWNER TO postgres;

--
-- Name: pk_gis_is_predefined_project; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_gis_is_predefined_project
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9223372036854775
    CACHE 1;


ALTER TABLE public.pk_gis_is_predefined_project OWNER TO postgres;

--
-- Name: pk_gis_is_predefined_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_gis_is_predefined_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 92233720368547758
    CACHE 1;


ALTER TABLE public.pk_gis_is_predefined_sequence OWNER TO postgres;

--
-- Name: pk_gis_proje_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pk_gis_proje_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9223372036854775
    CACHE 1;


ALTER TABLE public.pk_gis_proje_id_sequence OWNER TO postgres;

--
-- Name: r_report_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.r_report_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.r_report_attributes_id_seq OWNER TO postgres;

--
-- Name: r_report_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r_report_attributes (
    id integer DEFAULT nextval('public.r_report_attributes_id_seq'::regclass),
    parent_id integer DEFAULT 0,
    attr_id integer DEFAULT 0,
    name character varying(255),
    report_jasper_id integer DEFAULT 0,
    active integer DEFAULT 1,
    o_date timestamp with time zone DEFAULT now(),
    report_type integer DEFAULT 0
);


ALTER TABLE public.r_report_attributes OWNER TO postgres;

--
-- Name: r_report_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.r_report_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.r_report_types_id_seq OWNER TO postgres;

--
-- Name: r_report_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r_report_types (
    id integer DEFAULT nextval('public.r_report_types_id_seq'::regclass) NOT NULL,
    type_name character varying(100),
    active integer DEFAULT 0 NOT NULL,
    sort integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.r_report_types OWNER TO postgres;

--
-- Name: r_report_used_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.r_report_used_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.r_report_used_attributes_id_seq OWNER TO postgres;

--
-- Name: r_report_used_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r_report_used_attributes (
    id integer DEFAULT nextval('public.r_report_used_attributes_id_seq'::regclass),
    attr_id integer DEFAULT 0,
    report_configurations_id integer
);


ALTER TABLE public.r_report_used_attributes OWNER TO postgres;

--
-- Name: r_report_used_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.r_report_used_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.r_report_used_configurations_id_seq OWNER TO postgres;

--
-- Name: r_report_used_configurations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.r_report_used_configurations (
    id integer DEFAULT nextval('public.r_report_used_configurations_id_seq'::regclass),
    project_id integer DEFAULT 0 NOT NULL,
    user_id integer NOT NULL,
    report_jasper_id integer DEFAULT 0,
    report_type_id integer,
    r_date timestamp with time zone DEFAULT now(),
    report_name character varying(255),
    company_id integer DEFAULT '-99'::integer
);


ALTER TABLE public.r_report_used_configurations OWNER TO postgres;

--
-- Name: t_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_activity (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    international_code character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_activity OWNER TO postgres;

--
-- Name: t_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_activity_id_seq OWNER TO postgres;

--
-- Name: t_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_activity_id_seq OWNED BY public.t_activity.id;


--
-- Name: t_certificates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_certificates (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(150) NOT NULL
);


ALTER TABLE public.t_certificates OWNER TO postgres;

--
-- Name: t_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_certificates_id_seq OWNER TO postgres;

--
-- Name: t_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_certificates_id_seq OWNED BY public.t_certificates.id;


--
-- Name: t_cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cities (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.t_cities OWNER TO postgres;

--
-- Name: t_cities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cities_id_seq OWNER TO postgres;

--
-- Name: t_cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cities_id_seq OWNED BY public.t_cities.id;


--
-- Name: t_clstr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_clstr (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    active smallint NOT NULL,
    org_ind_reg_id integer NOT NULL
);


ALTER TABLE public.t_clstr OWNER TO postgres;

--
-- Name: t_clstr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_clstr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_clstr_id_seq OWNER TO postgres;

--
-- Name: t_clstr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_clstr_id_seq OWNED BY public.t_clstr.id;


--
-- Name: t_cmpnnt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpnnt (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    name_tr character varying(200),
    active smallint NOT NULL,
    cmpnt_type_id integer,
    cmpny_id integer
);


ALTER TABLE public.t_cmpnnt OWNER TO postgres;

--
-- Name: t_cmpnnt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpnnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpnnt_id_seq OWNER TO postgres;

--
-- Name: t_cmpnnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpnnt_id_seq OWNED BY public.t_cmpnnt.id;


--
-- Name: t_cmpnt_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpnt_type (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_cmpnt_type OWNER TO postgres;

--
-- Name: t_cmpnt_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpnt_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpnt_type_id_seq OWNER TO postgres;

--
-- Name: t_cmpnt_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpnt_type_id_seq OWNED BY public.t_cmpnt_type.id;


--
-- Name: t_cmpny; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    phone_num_1 character varying(50),
    phone_num_2 character varying(50),
    fax_num character varying(50),
    address character varying(100),
    description character varying(200),
    email character varying(150),
    postal_code character varying(50),
    logo character varying(60),
    active boolean,
    latitude character varying(25),
    longitude character varying(25),
    site character varying(150),
    city_id integer,
    country_id integer,
    turnover numeric(10,2),
    turnover_unit_id integer,
    infrastructure_id integer,
    surface_turnover numeric(10,2),
    surfaceturnover_unit integer,
    quickwins numeric(10,2),
    quickwins_unit integer,
    upperlimit_investments numeric(10,2),
    upperlimit_investments_unit integer,
    transportation_id integer,
    comments text,
    industrial_zone_id integer DEFAULT 0,
    cluster_id integer DEFAULT 0
);


ALTER TABLE public.t_cmpny OWNER TO postgres;

--
-- Name: t_cmpny_certificates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_certificates (
    id integer NOT NULL,
    cmpny_id integer NOT NULL,
    date date NOT NULL,
    certificate_id integer NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_cmpny_certificates OWNER TO postgres;

--
-- Name: t_cmpny_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_certificates_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_certificates_id_seq OWNED BY public.t_cmpny_certificates.id;


--
-- Name: t_cmpny_clstr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_clstr (
    cmpny_id integer NOT NULL,
    clstr_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_clstr OWNER TO postgres;

--
-- Name: t_cmpny_clstr_cmpny_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_clstr_cmpny_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_clstr_cmpny_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_clstr_cmpny_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_clstr_cmpny_id_seq OWNED BY public.t_cmpny_clstr.cmpny_id;


--
-- Name: t_cmpny_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_data (
    cmpny_id integer NOT NULL,
    description character varying(200)
);


ALTER TABLE public.t_cmpny_data OWNER TO postgres;

--
-- Name: t_cmpny_eqpmnt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_eqpmnt (
    id integer NOT NULL,
    cmpny_id integer,
    eqpmnt_id integer,
    eqpmnt_type_id integer,
    eqpmnt_type_attrbt_id integer,
    eqpmnt_attrbt_val integer,
    eqpmnt_attrbt_unit integer
);


ALTER TABLE public.t_cmpny_eqpmnt OWNER TO postgres;

--
-- Name: t_cmpny_eqpmnt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_eqpmnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_eqpmnt_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_eqpmnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_eqpmnt_id_seq OWNED BY public.t_cmpny_eqpmnt.id;


--
-- Name: t_cmpny_flow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_flow (
    id integer NOT NULL,
    cmpny_id integer,
    flow_id integer NOT NULL,
    qntty numeric(12,2),
    cost numeric(12,2),
    ep double precision,
    flow_type_id integer,
    potential_energy numeric(10,2),
    potential_energy_unit integer,
    supply_cost numeric(10,2),
    supply_cost_unit integer,
    transport_id integer,
    output_location character varying(255),
    substitute_potential character varying(500),
    comment text,
    data_quality character varying(250),
    entry_date timestamp without time zone DEFAULT now(),
    consultant_id integer,
    flow_category_id integer,
    function character varying(150),
    description character varying(500),
    chemical_formula character varying(100),
    availability boolean,
    concentration integer,
    pression integer,
    ph integer,
    state_id integer,
    quality character varying(150),
    min_flow_rate numeric(10,2),
    min_flow_rate_unit integer,
    max_flow_rate numeric(10,2),
    max_flow_rate_unit integer,
    cost_unit_id character varying(25),
    ep_unit_id character varying(25),
    qntty_unit_id integer,
    concunit character varying(50),
    presunit character varying(50),
    character_type character varying(50)
);


ALTER TABLE public.t_cmpny_flow OWNER TO postgres;

--
-- Name: t_cmpny_flow_cmpnnt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_flow_cmpnnt (
    cmpny_flow_id integer NOT NULL,
    cmpnnt_id integer NOT NULL,
    cmpnt_type_id integer DEFAULT 0 NOT NULL,
    qntty numeric(12,2),
    qntty_unit_id integer,
    supply_cost numeric(12,2),
    substitute_potential character varying(500),
    potential_energy numeric(12,2),
    potential_energy_unit integer,
    transport_id integer,
    output_cost numeric(12,2),
    output_location character varying(150),
    comment text,
    data_quality character varying(250),
    entry_date timestamp without time zone DEFAULT now(),
    description character varying(500),
    output_cost_unit character varying(25),
    supply_cost_unit character varying(25)
);
ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt ALTER COLUMN qntty SET STORAGE PLAIN;
ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt ALTER COLUMN supply_cost SET STORAGE PLAIN;
ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt ALTER COLUMN potential_energy SET STORAGE PLAIN;
ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt ALTER COLUMN output_cost SET STORAGE PLAIN;


ALTER TABLE public.t_cmpny_flow_cmpnnt OWNER TO postgres;

--
-- Name: t_cmpny_flow_cmpnnt_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_flow_cmpnnt_location (
    id integer NOT NULL,
    cmpny_flow_cmpnnt_index_test integer NOT NULL,
    supply_location text NOT NULL,
    supply_distance numeric(10,2) NOT NULL
);


ALTER TABLE public.t_cmpny_flow_cmpnnt_location OWNER TO postgres;

--
-- Name: t_cmpny_flow_cmpnnt_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_flow_cmpnnt_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_flow_cmpnnt_location_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_flow_cmpnnt_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_flow_cmpnnt_location_id_seq OWNED BY public.t_cmpny_flow_cmpnnt_location.id;


--
-- Name: t_cmpny_flow_cmpnnt_waste_threat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_flow_cmpnnt_waste_threat (
    id integer NOT NULL,
    cmpny_id integer NOT NULL,
    tec_id integer NOT NULL,
    cmpny_flow_cmpnnt_id integer NOT NULL,
    output_location text,
    output_distance numeric(10,2),
    transport_id integer
);


ALTER TABLE public.t_cmpny_flow_cmpnnt_waste_threat OWNER TO postgres;

--
-- Name: t_cmpny_flow_cmpnnt_waste_threat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_flow_cmpnnt_waste_threat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_flow_cmpnnt_waste_threat_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_flow_cmpnnt_waste_threat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_flow_cmpnnt_waste_threat_id_seq OWNED BY public.t_cmpny_flow_cmpnnt_waste_threat.id;


--
-- Name: t_cmpny_flow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_flow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_flow_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_flow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_flow_id_seq OWNED BY public.t_cmpny_flow.id;


--
-- Name: t_cmpny_flow_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_flow_location (
    id integer NOT NULL,
    cmpny_flow_id integer NOT NULL,
    supply_location text NOT NULL
);


ALTER TABLE public.t_cmpny_flow_location OWNER TO postgres;

--
-- Name: t_cmpny_flow_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_flow_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_flow_location_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_flow_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_flow_location_id_seq OWNED BY public.t_cmpny_flow_location.id;


--
-- Name: t_cmpny_flow_prcss; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_flow_prcss (
    cmpny_flow_id integer NOT NULL,
    cmpny_prcss_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_flow_prcss OWNER TO postgres;

--
-- Name: t_cmpny_grp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_grp (
    id integer NOT NULL,
    cmpny_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_grp OWNER TO postgres;

--
-- Name: t_cmpny_grp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_grp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_grp_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_grp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_grp_id_seq OWNED BY public.t_cmpny_grp.id;


--
-- Name: t_cmpny_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_id_seq OWNED BY public.t_cmpny.id;


--
-- Name: t_cmpny_nace_code; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_nace_code (
    cmpny_id integer NOT NULL,
    nace_code_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_nace_code OWNER TO postgres;

--
-- Name: t_cmpny_org_ind_reg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_org_ind_reg (
    org_ind_reg_id integer NOT NULL,
    cmpny_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_org_ind_reg OWNER TO postgres;

--
-- Name: t_cmpny_prcss; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_prcss (
    id integer NOT NULL,
    cmpny_id integer,
    prcss_id integer NOT NULL,
    prcss_family_id integer,
    min_rate_util integer,
    min_rate_util_unit integer,
    typ_rate_util integer,
    typ_rate_util_unit integer,
    max_rate_util integer,
    max_rate_util_unit integer,
    comment text
);


ALTER TABLE public.t_cmpny_prcss OWNER TO postgres;

--
-- Name: t_cmpny_prcss_eqpmnt_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_prcss_eqpmnt_type (
    cmpny_eqpmnt_type_id integer NOT NULL,
    cmpny_prcss_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_prcss_eqpmnt_type OWNER TO postgres;

--
-- Name: t_cmpny_prcss_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_prcss_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_prcss_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_prcss_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_prcss_id_seq OWNED BY public.t_cmpny_prcss.id;


--
-- Name: t_cmpny_production_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_production_details (
    id integer NOT NULL,
    cmpny_id integer NOT NULL,
    production_type_id integer,
    shift_total_week integer,
    production_closed integer
);


ALTER TABLE public.t_cmpny_production_details OWNER TO postgres;

--
-- Name: t_cmpny_production_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_production_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_production_details_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_production_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_production_details_id_seq OWNED BY public.t_cmpny_production_details.id;


--
-- Name: t_cmpny_prsnl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_prsnl (
    user_id integer NOT NULL,
    cmpny_id integer NOT NULL,
    is_contact smallint NOT NULL,
    key_column bigint NOT NULL
);


ALTER TABLE public.t_cmpny_prsnl OWNER TO postgres;

--
-- Name: t_cmpny_prsnl_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_prsnl_details (
    id integer NOT NULL,
    cmpny_id integer,
    grad_licence_cnt integer,
    grad_highschool_cnt integer,
    grad_tecnicalschool_cnt integer,
    foreman_cnt integer,
    grad_masterdegree_cnt integer,
    total_emp integer
);


ALTER TABLE public.t_cmpny_prsnl_details OWNER TO postgres;

--
-- Name: t_cmpny_prsnl_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_prsnl_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_prsnl_details_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_prsnl_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_prsnl_details_id_seq OWNED BY public.t_cmpny_prsnl_details.id;


--
-- Name: t_cmpny_prsnl_key_column_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_prsnl_key_column_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_prsnl_key_column_seq OWNER TO postgres;

--
-- Name: t_cmpny_prsnl_key_column_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_prsnl_key_column_seq OWNED BY public.t_cmpny_prsnl.key_column;


--
-- Name: t_cmpny_sector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cmpny_sector (
    id integer NOT NULL,
    cmpny_id integer NOT NULL,
    sector_id integer NOT NULL
);


ALTER TABLE public.t_cmpny_sector OWNER TO postgres;

--
-- Name: t_cmpny_sector_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cmpny_sector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cmpny_sector_id_seq OWNER TO postgres;

--
-- Name: t_cmpny_sector_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cmpny_sector_id_seq OWNED BY public.t_cmpny_sector.id;


--
-- Name: t_cnsltnt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cnsltnt (
    user_id integer NOT NULL,
    description character varying(200),
    active smallint NOT NULL
);


ALTER TABLE public.t_cnsltnt OWNER TO postgres;

--
-- Name: t_costbenefit_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_costbenefit_temp (
    cp_id integer,
    is_id integer,
    capexold numeric(13,2),
    "flow-name-1" character varying(40),
    "flow-value-1" character varying(40),
    "flow-unit-1" character varying(40),
    "flow-specost-1" character varying(40),
    "flow-opex-1" character varying(40),
    "flow-eipunit-1" character varying(40),
    "floweip-1" character varying(40),
    "annual-cost-1" character varying(40),
    ltold character varying(40),
    investment character varying(40),
    disrate character varying(40),
    "capex-1" character varying(40),
    "flow-name-2" character varying(40),
    "flow-value-2" character varying(40),
    "flow-unit-2" character varying(40),
    "flow-specost-2" character varying(40),
    "flow-opex-2" character varying(40),
    "flow-eipunit-2" character varying(40),
    "flow-eip-2" character varying(40),
    "annual-cost-2" character varying(40),
    "flow-name-3" character varying(40),
    "flow-value-3" character varying(40),
    "flow-unit-3" character varying(40),
    "flow-opex-3" character varying(40),
    "ecoben-1" character varying(40),
    "ecoben-eip-1" character varying(40),
    "marcos-1" character varying(40),
    "payback-1" character varying(40),
    "flow-name-1-2" character varying(40),
    "flow-value-1-2" character varying(40),
    "flow-unit-1-2" character varying(40),
    "flow-specost-1-2" character varying(40),
    "flow-opex-1-2" character varying(40),
    "flow-eipunit-1-2" character varying(40),
    "flow-eip-1-2" character varying(40),
    "flow-name-2-2" character varying(40),
    "flow-value-2-2" character varying(40),
    "flow-unit-2-2" character varying(40),
    "flow-specost-2-2" character varying(40),
    "flow-opex-2-2" character varying(40),
    "flow-eipunit-2-2" character varying(40),
    "flow-eip-2-2" character varying(40),
    "flow-name-3-2" character varying(40),
    "flow-value-3-2" character varying(40),
    "flow-unit-3-2" character varying(40),
    "flow-opex-3-2" character varying(40),
    "ecoben-eip-1-2" character varying(40),
    "flow-name-1-3" character varying(40),
    "flow-value-1-3" character varying(40),
    "flow-unit-1-3" character varying(40),
    "flow-specost-1-3" character varying(40),
    "flow-opex-1-3" character varying(40),
    "flow-eipunit-1-3" character varying(40),
    "flow-eip-1-3" character varying(40),
    "flow-name-2-3" character varying(40),
    "flow-value-2-3" character varying(40),
    "flow-unit-2-3" character varying(40),
    "flow-specost-2-3" character varying(40),
    "flow-opex-2-3" character varying(40),
    "flow-eipunit-2-3" character varying(40),
    "flow-eip-2-3" character varying(40),
    "flow-name-3-3" character varying(40),
    "flow-value-3-3" character varying(40),
    "flow-unit-3-3" character varying(40),
    "flow-opex-3-3" character varying(40),
    "ecoben-eip-1-3" character varying(40),
    "flow-name-1-4" character varying(40),
    "flow-value-1-4" character varying(40),
    "flow-unit-1-4" character varying(40),
    "flow-specost-1-4" character varying(40),
    "flow-opex-1-4" character varying(40),
    "flow-eipunit-1-4" character varying(40),
    "flow-eip-1-4" character varying(40),
    "flow-name-1-5" character varying(40),
    "flow-value-1-5" character varying(40),
    "flow-unit-1-5" character varying(40),
    "flow-specost-1-5" character varying(40),
    "flow-opex-1-5" character varying(40),
    "flow-eipunit-1-5" character varying(40),
    "flow-eip-1-5" character varying(40),
    "flow-name-2-5" character varying(40),
    "flow-value-2-5" character varying(40),
    "flow-unit-2-5" character varying(40),
    "flow-specost-2-5" character varying(40),
    "flow-opex-2-5" character varying(40),
    "flow-eipunit-2-5" character varying(40),
    "flow-eip-2-5" character varying(40),
    "flow-name-3-5" character varying(40),
    "flow-value-3-5" character varying(40),
    "flow-unit-3-5" character varying(40),
    "flow-opex-3-5" character varying(40),
    "ecoben-eip-1-5" character varying(40),
    "flow-name-1-6" character varying(40),
    "flow-value-1-6" character varying(40),
    "flow-unit-1-6" character varying(40),
    "flow-specost-1-6" character varying(40),
    "flow-opex-1-6" character varying(40),
    "flow-eipunit-1-6" character varying(40),
    "flow-eip-1-6" character varying(40),
    "flow-name-2-6" character varying(40),
    "flow-value-2-6" character varying(40),
    "flow-unit-2-6" character varying(40),
    "flow-specost-2-6" character varying(40),
    "flow-opex-2-6" character varying(40),
    "flow-eipunit-2-6" character varying(40),
    "flow-eip-2-6" character varying(40),
    "flow-name-3-6" character varying(40),
    "flow-value-3-6" character varying(40),
    "flow-unit-3-6" character varying(40),
    "flow-opex-3-6" character varying(40),
    "ecoben-eip-1-6" character varying(40),
    "maintan-1" character varying(40),
    "sum-1" character varying(40),
    "sum-2" character varying(40),
    "maintan-1-2" character varying(40),
    "sum-1-1" character varying(40),
    "sum-2-1" character varying(40),
    "sum-3-1" character varying(40),
    "sum-3-2" character varying(40),
    "flow-name-2-4" character varying(40),
    "flow-value-2-4" character varying(40),
    "flow-unit-2-4" character varying(40),
    "flow-specost-2-4" character varying(40),
    "flow-opex-2-4" character varying(40),
    "flow-eipunit-2-4" character varying(40),
    "flow-eip-2-4" character varying(40),
    "flow-name-3-4" character varying(40),
    "flow-value-3-4" character varying(40),
    "flow-unit-3-4" character varying(40),
    "flow-opex-3-4" character varying(40),
    "ecoben-eip-1-4" character varying(40),
    pkey integer NOT NULL
);


ALTER TABLE public.t_costbenefit_temp OWNER TO postgres;

--
-- Name: t_costbenefit_temp_pkey_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_costbenefit_temp_pkey_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_costbenefit_temp_pkey_seq OWNER TO postgres;

--
-- Name: t_costbenefit_temp_pkey_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_costbenefit_temp_pkey_seq OWNED BY public.t_costbenefit_temp.pkey;


--
-- Name: t_country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_country (
    id integer NOT NULL,
    iso character(2) NOT NULL,
    name character varying(80) NOT NULL,
    printable_name character varying(80) NOT NULL,
    iso3 character(3),
    numcode smallint
);


ALTER TABLE public.t_country OWNER TO postgres;

--
-- Name: t_country_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_country_id_seq OWNER TO postgres;

--
-- Name: t_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_country_id_seq OWNED BY public.t_country.id;


--
-- Name: t_cp_allocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cp_allocation (
    id integer NOT NULL,
    prcss_id integer NOT NULL,
    flow_id integer NOT NULL,
    flow_type_id integer NOT NULL,
    amount numeric(13,2),
    unit_amount character varying(25),
    allocation_amount numeric(13,2),
    cost numeric(13,2),
    unit_cost character varying(25),
    allocation_cost numeric(13,2),
    env_impact numeric(25,2),
    unit_env_impact character varying(25),
    allocation_env_impact character varying(25),
    reference numeric(25,3),
    unit_reference character varying(250),
    kpi double precision,
    unit_kpi character varying(250),
    kpi_error numeric(6,2),
    benchmark_kpi double precision,
    best_practice character varying(250),
    capexold numeric(13,2),
    ltold numeric(6,2),
    capexnew numeric(13,2),
    ltnew numeric(6,2),
    newcons numeric(13,2),
    disrate numeric(6,2),
    marcos numeric(13,2),
    ecoben numeric(13,2),
    error_cost integer,
    error_amount integer,
    error_ep integer,
    option integer DEFAULT 1,
    nameofref character varying(100),
    kpidef character varying(250),
    opexold numeric(13,2),
    opexnew numeric(13,2),
    anncostold numeric(13,2),
    anncostnew numeric(13,2),
    ecocosben numeric(13,2),
    unit1 character varying(10),
    oldtotalcons numeric(18,2),
    oldtotalcost numeric(18,2),
    oldtotalep numeric(18,2),
    unit2 character varying(10),
    ecobenunit character varying(10),
    marcosunit character varying(10),
    description character varying(500)
);


ALTER TABLE public.t_cp_allocation OWNER TO postgres;

--
-- Name: t_cp_allocation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cp_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cp_allocation_id_seq OWNER TO postgres;

--
-- Name: t_cp_allocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cp_allocation_id_seq OWNED BY public.t_cp_allocation.id;


--
-- Name: t_cp_company_project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cp_company_project (
    id integer NOT NULL,
    allocation_id integer NOT NULL,
    prjct_id integer NOT NULL,
    cmpny_id integer NOT NULL
);


ALTER TABLE public.t_cp_company_project OWNER TO postgres;

--
-- Name: t_cp_company_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cp_company_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cp_company_project_id_seq OWNER TO postgres;

--
-- Name: t_cp_company_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cp_company_project_id_seq OWNED BY public.t_cp_company_project.id;


--
-- Name: t_cp_is_candidate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cp_is_candidate (
    id integer NOT NULL,
    allocation_id integer NOT NULL,
    active integer NOT NULL
);


ALTER TABLE public.t_cp_is_candidate OWNER TO postgres;

--
-- Name: t_cp_is_candidate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cp_is_candidate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cp_is_candidate_id_seq OWNER TO postgres;

--
-- Name: t_cp_is_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cp_is_candidate_id_seq OWNED BY public.t_cp_is_candidate.id;


--
-- Name: t_cp_scoping_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_cp_scoping_files (
    id integer NOT NULL,
    prjct_id integer NOT NULL,
    cmpny_id integer NOT NULL,
    file_name character varying(250)
);


ALTER TABLE public.t_cp_scoping_files OWNER TO postgres;

--
-- Name: t_cp_scoping_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_cp_scoping_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_cp_scoping_files_id_seq OWNER TO postgres;

--
-- Name: t_cp_scoping_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_cp_scoping_files_id_seq OWNED BY public.t_cp_scoping_files.id;


--
-- Name: t_district; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_district (
    id bigint NOT NULL,
    city_id bigint,
    name text
);


ALTER TABLE public.t_district OWNER TO postgres;

--
-- Name: t_district_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_district_id_seq OWNER TO postgres;

--
-- Name: t_district_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_district_id_seq OWNED BY public.t_district.id;


--
-- Name: t_doc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_doc (
    id integer NOT NULL,
    doc character varying(40),
    description character varying(200)
);


ALTER TABLE public.t_doc OWNER TO postgres;

--
-- Name: t_doc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_doc_id_seq OWNER TO postgres;

--
-- Name: t_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_doc_id_seq OWNED BY public.t_doc.id;


--
-- Name: t_ecotracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_ecotracking (
    id bigint NOT NULL,
    company_id integer,
    powera numeric(5,2),
    powerb numeric(5,2),
    powerc numeric(5,2),
    date timestamp without time zone,
    machine_id integer
);


ALTER TABLE public.t_ecotracking OWNER TO postgres;

--
-- Name: t_ecotracking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_ecotracking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_ecotracking_id_seq OWNER TO postgres;

--
-- Name: t_ecotracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_ecotracking_id_seq OWNED BY public.t_ecotracking.id;


--
-- Name: t_eqpmnt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_eqpmnt (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    name_tr character varying(200),
    active smallint NOT NULL,
    eqpmnt_type_id integer
);


ALTER TABLE public.t_eqpmnt OWNER TO postgres;

--
-- Name: t_eqpmnt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_eqpmnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_eqpmnt_id_seq OWNER TO postgres;

--
-- Name: t_eqpmnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_eqpmnt_id_seq OWNED BY public.t_eqpmnt.id;


--
-- Name: t_eqpmnt_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_eqpmnt_type (
    id integer NOT NULL,
    name character varying(200),
    name_tr character varying(200),
    mother_id integer,
    active smallint NOT NULL
);


ALTER TABLE public.t_eqpmnt_type OWNER TO postgres;

--
-- Name: t_eqpmnt_type_attrbt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_eqpmnt_type_attrbt (
    id integer NOT NULL,
    attribute_name character varying(50),
    attribute_name_tr character varying(50),
    attribute_value character varying(200),
    eqpmnt_type_id integer,
    active smallint
);


ALTER TABLE public.t_eqpmnt_type_attrbt OWNER TO postgres;

--
-- Name: t_eqpmnt_type_attrbt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_eqpmnt_type_attrbt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_eqpmnt_type_attrbt_id_seq OWNER TO postgres;

--
-- Name: t_eqpmnt_type_attrbt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_eqpmnt_type_attrbt_id_seq OWNED BY public.t_eqpmnt_type_attrbt.id;


--
-- Name: t_eqpmnt_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_eqpmnt_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_eqpmnt_type_id_seq OWNER TO postgres;

--
-- Name: t_eqpmnt_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_eqpmnt_type_id_seq OWNED BY public.t_eqpmnt_type.id;


--
-- Name: t_flow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_flow (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    name_tr character varying(200),
    active smallint NOT NULL,
    flow_family_id integer
);


ALTER TABLE public.t_flow OWNER TO postgres;

--
-- Name: t_flow_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_flow_category (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    flow_type_id integer NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_flow_category OWNER TO postgres;

--
-- Name: t_flow_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_category_id_seq OWNER TO postgres;

--
-- Name: t_flow_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_category_id_seq OWNED BY public.t_flow_category.id;


--
-- Name: t_flow_family; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_flow_family (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_flow_family OWNER TO postgres;

--
-- Name: t_flow_family_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_family_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_family_id_seq OWNER TO postgres;

--
-- Name: t_flow_family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_family_id_seq OWNED BY public.t_flow_family.id;


--
-- Name: t_flow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_id_seq OWNER TO postgres;

--
-- Name: t_flow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_id_seq OWNED BY public.t_flow.id;


--
-- Name: t_flow_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_flow_log (
    id integer NOT NULL,
    flow_id integer NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    name character varying(200) NOT NULL,
    name_tr character varying(200),
    active smallint NOT NULL,
    flow_family_id integer,
    log_operation_type integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.t_flow_log OWNER TO postgres;

--
-- Name: t_flow_log_flow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_log_flow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_log_flow_id_seq OWNER TO postgres;

--
-- Name: t_flow_log_flow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_log_flow_id_seq OWNED BY public.t_flow_log.flow_id;


--
-- Name: t_flow_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_log_id_seq OWNER TO postgres;

--
-- Name: t_flow_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_log_id_seq OWNED BY public.t_flow_log.id;


--
-- Name: t_flow_total_per_cmpny; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_flow_total_per_cmpny (
    cmpny_id bigint,
    "Water" json,
    "Electricity" json,
    "Aliminium" json,
    "Brass" json,
    "Copper" json,
    "Lead" json,
    "Zinc" json,
    "Acetone" json,
    "Ketone" json,
    "Acetoin" json,
    "Ethanol" json,
    "Peroxide" json,
    "WoodCips" json,
    "Cellulose" json,
    cmpny_name character varying(300),
    id bigint NOT NULL,
    yeniflow json,
    "rule test" json,
    "rule test2" json,
    "rule test3" json,
    "rule test4" json,
    "rule test5" json,
    "Deneme" json,
    "Deneme2" json,
    wood json,
    nuts json,
    steel json,
    titanium json,
    aliuminium json,
    plastic json,
    aluminium json,
    csteel json,
    test json,
    zeynel json,
    wastewater json,
    "flow1compI" json,
    "flow2compI" json,
    "flow3compI" json,
    "flow4compI" json,
    "flow1compG" json,
    "flow2compG" json,
    "flow3compG" json,
    "flow4compG" json,
    fuel json,
    "Additives" json,
    "Dust" json,
    "EmissionToAir" json,
    "Residues" json,
    "RecoveredPaper" json,
    "WoodChips" json,
    "Paper" json,
    "Color" json,
    "Solvents" json,
    "Newspapers" json,
    wastepaper json,
    "Municipalwaste" json,
    "Municipal_waste" json,
    concrete json,
    "PE" json,
    "Polysthyrene" json,
    "Cement" json,
    "Natural_gas" json,
    "Heat" json,
    cutting_fluid json,
    cuttingfluid json,
    ldpe json,
    electricity json,
    dust json,
    packagingwaste json,
    cuttingtools json,
    vesconite json,
    cleaner json,
    cuttingoil json,
    "tuna ├ğa─şlar test" json,
    "tuna caglar gumus" json,
    testttttt json,
    "b├╝y├╝k flow deneme" json,
    "b├╝y├╝k" json,
    test21 json,
    test32 json,
    test22 json,
    "test 23" json,
    testtun json,
    test12 json,
    "tuna gumus" json,
    arsenic json,
    "printing plate" json,
    "used printing plates" json,
    fluegas json,
    "tuna ├ğa─şlar" json,
    "ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj" json,
    cuivre json,
    "wood pallet" json,
    steam json,
    "huile vegetale" json,
    argile json,
    gravier json,
    eau json,
    "hello space" json,
    "fuel oil" json,
    "cleaner 2" json,
    "cooling emulsion" json,
    cardboard json,
    "plastic foil" json,
    sand json,
    "special waste" json,
    "plastic waste" json,
    aluminyum json,
    elektrik json,
    galvaniz json,
    "kesme s─▒v─▒s─▒" json,
    "aluminyum tala┼ş" json,
    "aluminyum hurda" json,
    "at─▒k ─▒s─▒" json,
    "ka─ş─▒t at─▒k" json,
    duman json,
    asit json,
    "at─▒k su" json,
    "at─▒k ya─ş" json,
    "├╝st├╝b├╝" json,
    "kesim ├╝r├╝n├╝" json,
    "torna ├╝r├╝n├╝" json,
    "s─▒cak ┼şekillendirme ├╝r├╝n├╝" json,
    lpg json,
    "s─▒cak d├Âvme ├╝r├╝n├╝" json,
    "kumlama ├╝r├╝n├╝" json,
    "di┼ş a├ğma ├╝r├╝n├╝" json,
    ambalaj json,
    light json,
    lightening json,
    dissolver json,
    "wooden box" json,
    "synthetic material" json,
    box json,
    "heat in waste water" json,
    "heat from cooling system" json,
    lactoserum json,
    "organic waste" json,
    "fired clay" json,
    phosphate json,
    "phosphoric acid" json,
    "concrete and gravel" json,
    detergent json,
    "spent cutting fluid" json,
    malt json,
    "plastic bottles" json,
    fructose json,
    concentrate json,
    "glass bottle" json,
    flatglass json,
    "waste glass" json,
    spacer json,
    "waste spacer" json,
    "safety glass" json,
    acetylcellulose json,
    paint json,
    "acetone and acetylcellulose solution" json,
    "electricity to chemical bar" json,
    oil json,
    "sodium hydroxide" json,
    "cotton filters" json,
    carbon json,
    packaging json,
    ibi json,
    testflow json,
    fat json,
    milk json,
    raw_milk json,
    electricity_lv_rer json,
    water_and_wastewater_ch json,
    awdwad json,
    etetet json,
    phosphoric_acid json,
    sodium_hydroxide json,
    district_heat_mswi json,
    water json,
    rawmilk_losses json,
    electricity_ch json,
    paper json,
    paper_waste json,
    chemical_for_cold_sterlilisation json,
    district_heat_from_waste_incineration_plant json,
    water_at_tap json,
    mainly_from_coal_and_nuclear_power_plants json,
    rawmilk_from_cow_farms json,
    phosphoric_acid_for_cip_cleaning json,
    sodium_hydroxide_for_cip_cleaning json,
    waste_water_with_high_organic_load json,
    halades_pe_15 json,
    heat_mswi json,
    electricity_fossil json,
    rawmilk json,
    electricity_mix json,
    sterilisation_chemical json,
    hop json,
    yeast json,
    caustic_soda json,
    district_heat json,
    processed_milk json,
    helades_pe_15 json,
    water_for_cold_sterilisation json,
    wastewater_cold_sterilisation json,
    hot_water_for_sterilisation json,
    wastewater_hot_sterilisation json,
    heat_hot_sterilisation json,
    electricity_for_hot_sterilisation json,
    fresh_water json,
    waste_water_general json,
    hot_water_general json,
    refrigerant_r407c json,
    plastic_waste json,
    release_into_air_refrigerant_r407c json,
    petcoke json,
    co2 json,
    nitrogen_oxides json,
    ammonia json,
    awdad json,
    "Meal with chicken" json,
    "TEST" json,
    "Cow milk" json,
    "Electricity CH medium Voltage" json,
    "Heat borehole heat pump CH" json,
    "Phosphoric acid industrial grade" json,
    "Sodium Hydroxide" json,
    "Tap water" json,
    "Raw Milk" json,
    "Raw Milk Loss" json,
    "Waste Water" json,
    "Heat air water heat pump CH" json,
    "Electricity EU low Voltage" json,
    "xTestEPKim" json,
    "Wasterwater treatment CH" json,
    "Vegetarian meal" json,
    "Freight lorry t" json,
    "Cladding" json,
    "Soybean" json,
    "Freight transoceanic ship World" json,
    "Freight train CH" json,
    "Heat natural gas CH" json,
    "Heat natural gas heat and power cogeneration CH" json,
    "Electricity from hydro reservoir in alpine region CH high Volta" json,
    "Barley grain" json,
    "Hydrochloric acid" json,
    "Plywood outdoor use" json,
    "Horticultural fleece" json,
    "Electricity World medium Voltage" json,
    nutritivebiomass json,
    "Nutritionswine" json,
    "Maltcake" json,
    "Wheat grain" json,
    "Heat from biogas heat and power cogeneration CH" json,
    "Dionised water" json,
    "Electricity photovoltaic aSi panel CH low Voltage" json,
    "Nutritive Biomass" json,
    "Nucler fuel" json,
    "Milk" json,
    "Plywood indoor use" json,
    "Chromium steel stainless" json,
    "Electricity from municipal waste incineration CH medium Voltage" json,
    "Concrete normal" json,
    "Aluminium primary ingot" json,
    "Limestone" json,
    "Aluminium" json,
    "Heat Natural Gas" json,
    "Steel chromium" json,
    "Hardwood" json,
    "Heat Gas" json,
    "Wood" json,
    "Water ukr" json,
    "Heat natural gas" json,
    "Petcoke Consumption Baseline" json,
    "RDF burning" json,
    "MSW transport" json,
    "Electricity RDF" json,
    "District heating" json,
    "Energy mix swiss" json,
    "Fresh water" json,
    "Fresh  waste Water" json,
    "Fernwrme" json,
    "Oil heating" json,
    "Strom" json,
    "water  ARA" json,
    "Waste incineration plastic" json,
    "Phosphoric Acid" json,
    "Dust emission" json,
    "NOx Emission" json,
    "Ammonia" json,
    "Electricity Dust" json,
    "Petcoke" json,
    "NOx" json,
    "Petcokee" json,
    "Biogas" json,
    "Textile cotton based" json,
    "Palm oil" json,
    "Sugar from sugarbeet" json,
    "Carrot" json,
    "Wasser" json,
    "Hydrogen peroxide" json,
    "Soap" json,
    "Reaktivfarbstoff" json,
    "Farbstoff" json,
    "Treber" json,
    "Incineration of hazardous waste CH" json
);


ALTER TABLE public.t_flow_total_per_cmpny OWNER TO postgres;

--
-- Name: t_flow_total_per_cmpny_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_total_per_cmpny_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_total_per_cmpny_id_seq OWNER TO postgres;

--
-- Name: t_flow_total_per_cmpny_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_total_per_cmpny_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_total_per_cmpny_id_seq1 OWNER TO postgres;

--
-- Name: t_flow_total_per_cmpny_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_total_per_cmpny_id_seq1 OWNED BY public.t_flow_total_per_cmpny.id;


--
-- Name: t_flow_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_flow_type (
    id integer NOT NULL,
    name character varying(200),
    name_tr character varying(200),
    active smallint NOT NULL
);


ALTER TABLE public.t_flow_type OWNER TO postgres;

--
-- Name: t_flow_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_flow_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_flow_type_id_seq OWNER TO postgres;

--
-- Name: t_flow_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_flow_type_id_seq OWNED BY public.t_flow_type.id;


--
-- Name: t_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_group OWNER TO postgres;

--
-- Name: t_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_group_id_seq OWNER TO postgres;

--
-- Name: t_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_group_id_seq OWNED BY public.t_group.id;


--
-- Name: t_infrastructure; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_infrastructure (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.t_infrastructure OWNER TO postgres;

--
-- Name: t_infrastructure_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_infrastructure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_infrastructure_id_seq OWNER TO postgres;

--
-- Name: t_infrastructure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_infrastructure_id_seq OWNED BY public.t_infrastructure.id;


--
-- Name: t_is_prj; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_is_prj (
    id integer NOT NULL,
    synergy_id integer NOT NULL,
    consultant_id integer NOT NULL,
    active smallint DEFAULT 1 NOT NULL,
    prj_date timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(150) NOT NULL,
    status integer,
    prj_id bigint
);


ALTER TABLE public.t_is_prj OWNER TO postgres;

--
-- Name: t_is_prj_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_is_prj_details (
    id integer NOT NULL,
    cmpny_from_id integer,
    cmpny_to_id integer,
    flow_id integer,
    from_quantity integer,
    to_quantity integer,
    unit_id integer,
    is_prj_id integer NOT NULL,
    flow_id_to integer,
    to_unit_id integer,
    to_flow_type_id integer
);


ALTER TABLE public.t_is_prj_details OWNER TO postgres;

--
-- Name: t_is_prj_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_is_prj_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_is_prj_details_id_seq OWNER TO postgres;

--
-- Name: t_is_prj_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_is_prj_details_id_seq OWNED BY public.t_is_prj_details.id;


--
-- Name: t_is_prj_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_is_prj_history (
    id integer NOT NULL,
    cmpny_from_id integer,
    cmpny_to_id integer,
    flow_id integer,
    from_quantity integer,
    to_quantity integer,
    unit_id integer,
    is_prj_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.t_is_prj_history OWNER TO postgres;

--
-- Name: t_is_prj_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_is_prj_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_is_prj_history_id_seq OWNER TO postgres;

--
-- Name: t_is_prj_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_is_prj_history_id_seq OWNED BY public.t_is_prj_history.id;


--
-- Name: t_is_prj_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_is_prj_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_is_prj_id_seq OWNER TO postgres;

--
-- Name: t_is_prj_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_is_prj_id_seq OWNED BY public.t_is_prj.id;


--
-- Name: t_is_prj_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_is_prj_status (
    id integer NOT NULL,
    name character varying(200),
    name_tr character varying(200),
    active smallint NOT NULL
);


ALTER TABLE public.t_is_prj_status OWNER TO postgres;

--
-- Name: t_is_prj_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_is_prj_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_is_prj_status_id_seq OWNER TO postgres;

--
-- Name: t_is_prj_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_is_prj_status_id_seq OWNED BY public.t_is_prj_status.id;


--
-- Name: t_log_operation_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_log_operation_type (
    id integer NOT NULL,
    operation_type character varying(200) NOT NULL
);


ALTER TABLE public.t_log_operation_type OWNER TO postgres;

--
-- Name: t_log_operation_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_log_operation_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_log_operation_type_id_seq OWNER TO postgres;

--
-- Name: t_log_operation_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_log_operation_type_id_seq OWNED BY public.t_log_operation_type.id;


--
-- Name: t_nace_code; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_nace_code (
    id integer NOT NULL,
    code character varying(255) NOT NULL
);


ALTER TABLE public.t_nace_code OWNER TO postgres;

--
-- Name: t_nace_code_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_nace_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_nace_code_id_seq OWNER TO postgres;

--
-- Name: t_nace_code_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_nace_code_id_seq OWNED BY public.t_nace_code.id;


--
-- Name: t_nace_code_rev2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_nace_code_rev2 (
    id smallint NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    active integer NOT NULL
);


ALTER TABLE public.t_nace_code_rev2 OWNER TO postgres;

--
-- Name: t_nace_code_rev2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_nace_code_rev2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_nace_code_rev2_id_seq OWNER TO postgres;

--
-- Name: t_nace_code_rev2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_nace_code_rev2_id_seq OWNED BY public.t_nace_code_rev2.id;


--
-- Name: t_org_ind_reg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_org_ind_reg (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    active smallint NOT NULL,
    country character varying(50)
);


ALTER TABLE public.t_org_ind_reg OWNER TO postgres;

--
-- Name: t_org_ind_reg_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_org_ind_reg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_org_ind_reg_id_seq OWNER TO postgres;

--
-- Name: t_org_ind_reg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_org_ind_reg_id_seq OWNED BY public.t_org_ind_reg.id;


--
-- Name: t_prcss; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prcss (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    name_tr character varying(200),
    mother_id integer,
    active smallint NOT NULL,
    layer integer NOT NULL,
    description text,
    prcss_family_id integer
);


ALTER TABLE public.t_prcss OWNER TO postgres;

--
-- Name: t_prcss_family; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prcss_family (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_prcss_family OWNER TO postgres;

--
-- Name: t_prcss_family_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_prcss_family_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_prcss_family_id_seq OWNER TO postgres;

--
-- Name: t_prcss_family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_prcss_family_id_seq OWNED BY public.t_prcss_family.id;


--
-- Name: t_prcss_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_prcss_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_prcss_id_seq OWNER TO postgres;

--
-- Name: t_prcss_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_prcss_id_seq OWNED BY public.t_prcss.id;


--
-- Name: t_prdct; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prdct (
    id integer NOT NULL,
    cmpny_id integer,
    name character varying(200) NOT NULL,
    quantities double precision,
    ucost double precision,
    ucostu character varying(40),
    tper character varying(40),
    qunit character varying(40)
);


ALTER TABLE public.t_prdct OWNER TO postgres;

--
-- Name: t_prdct_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_prdct_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_prdct_id_seq OWNER TO postgres;

--
-- Name: t_prdct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_prdct_id_seq OWNED BY public.t_prdct.id;


--
-- Name: t_prj; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    start_date date NOT NULL,
    end_date date,
    status_id integer NOT NULL,
    description character varying(200),
    active smallint NOT NULL,
    latitude character varying(25) DEFAULT 39.97677605064184,
    longitude character varying(25) DEFAULT 32.74086490098853,
    zoomlevel integer
);


ALTER TABLE public.t_prj OWNER TO postgres;

--
-- Name: t_prj_acss_cmpny; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_acss_cmpny (
    cmpny_id integer NOT NULL,
    prj_id integer NOT NULL,
    read_acss smallint,
    write_acss smallint,
    delete_acss smallint
);


ALTER TABLE public.t_prj_acss_cmpny OWNER TO postgres;

--
-- Name: t_prj_acss_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_acss_user (
    user_id integer NOT NULL,
    prj_id integer NOT NULL,
    read_acss smallint,
    write_acss smallint,
    delete_acss smallint
);


ALTER TABLE public.t_prj_acss_user OWNER TO postgres;

--
-- Name: t_prj_cmpny; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_cmpny (
    prj_id integer NOT NULL,
    cmpny_id integer NOT NULL
);


ALTER TABLE public.t_prj_cmpny OWNER TO postgres;

--
-- Name: t_prj_cnsltnt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_cnsltnt (
    prj_id integer NOT NULL,
    cnsltnt_id integer NOT NULL,
    active smallint
);


ALTER TABLE public.t_prj_cnsltnt OWNER TO postgres;

--
-- Name: t_prj_cntct_prsnl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_cntct_prsnl (
    prj_id integer NOT NULL,
    usr_id integer NOT NULL,
    description character varying(200)
);


ALTER TABLE public.t_prj_cntct_prsnl OWNER TO postgres;

--
-- Name: t_prj_doc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_doc (
    doc_id integer NOT NULL,
    prj_id integer NOT NULL
);


ALTER TABLE public.t_prj_doc OWNER TO postgres;

--
-- Name: t_prj_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_prj_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_prj_id_seq OWNER TO postgres;

--
-- Name: t_prj_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_prj_id_seq OWNED BY public.t_prj.id;


--
-- Name: t_prj_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_prj_status (
    id integer NOT NULL,
    name character varying(200),
    name_tr character varying(200),
    active smallint NOT NULL,
    short_code character varying(3)
);


ALTER TABLE public.t_prj_status OWNER TO postgres;

--
-- Name: t_prj_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_prj_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_prj_status_id_seq OWNER TO postgres;

--
-- Name: t_prj_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_prj_status_id_seq OWNED BY public.t_prj_status.id;


--
-- Name: t_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_role (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    name_tr character varying(100),
    active boolean NOT NULL,
    short_code character varying(3)
);


ALTER TABLE public.t_role OWNER TO postgres;

--
-- Name: t_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_role_id_seq OWNER TO postgres;

--
-- Name: t_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_role_id_seq OWNED BY public.t_role.id;


--
-- Name: t_sector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_sector (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_sector OWNER TO postgres;

--
-- Name: t_sector_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_sector_activity (
    id integer NOT NULL,
    sector_id integer NOT NULL,
    activity_id integer NOT NULL
);


ALTER TABLE public.t_sector_activity OWNER TO postgres;

--
-- Name: t_sector_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_sector_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_sector_activity_id_seq OWNER TO postgres;

--
-- Name: t_sector_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_sector_activity_id_seq OWNED BY public.t_sector_activity.id;


--
-- Name: t_sector_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_sector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_sector_id_seq OWNER TO postgres;

--
-- Name: t_sector_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_sector_id_seq OWNED BY public.t_sector.id;


--
-- Name: t_state; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_state (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_state OWNER TO postgres;

--
-- Name: t_state_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_state_id_seq OWNER TO postgres;

--
-- Name: t_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_state_id_seq OWNED BY public.t_state.id;


--
-- Name: t_synergy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_synergy (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_synergy OWNER TO postgres;

--
-- Name: t_synergy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_synergy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_synergy_id_seq OWNER TO postgres;

--
-- Name: t_synergy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_synergy_id_seq OWNED BY public.t_synergy.id;


--
-- Name: t_transport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_transport (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_transport OWNER TO postgres;

--
-- Name: t_transport_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_transport_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_transport_id_seq OWNER TO postgres;

--
-- Name: t_transport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_transport_id_seq OWNED BY public.t_transport.id;


--
-- Name: t_transportation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_transportation (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_transportation OWNER TO postgres;

--
-- Name: t_transportation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_transportation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_transportation_id_seq OWNER TO postgres;

--
-- Name: t_transportation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_transportation_id_seq OWNED BY public.t_transportation.id;


--
-- Name: t_unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_unit (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    name_tr character varying(200),
    active smallint NOT NULL,
    unit_type_id integer DEFAULT (1)::numeric
);


ALTER TABLE public.t_unit OWNER TO postgres;

--
-- Name: t_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_unit_id_seq OWNER TO postgres;

--
-- Name: t_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_unit_id_seq OWNED BY public.t_unit.id;


--
-- Name: t_unit_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_unit_type (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_unit_type OWNER TO postgres;

--
-- Name: t_unit_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_unit_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_unit_type_id_seq OWNER TO postgres;

--
-- Name: t_unit_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_unit_type_id_seq OWNED BY public.t_unit_type.id;


--
-- Name: t_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_user (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    surname character varying(100) NOT NULL,
    user_name character varying(50),
    psswrd character varying(40),
    role_id integer DEFAULT (2)::numeric,
    title character varying(255),
    phone_num_1 character varying(50),
    phone_num_2 character varying(50),
    fax_num character varying(50),
    email character varying(150),
    description character varying(200),
    linkedin_user boolean,
    photo character varying(60),
    active boolean,
    random_string character varying(20),
    click_control integer,
    industrial_zone_id integer DEFAULT 0,
    department_id integer DEFAULT 0
);


ALTER TABLE public.t_user OWNER TO postgres;

--
-- Name: t_user_ep_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_user_ep_values (
    user_id integer NOT NULL,
    ep_value double precision,
    flow_name character varying(255),
    primary_id bigint NOT NULL,
    ep_q_unit integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.t_user_ep_values OWNER TO postgres;

--
-- Name: t_user_ep_values_primary_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_user_ep_values_primary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_user_ep_values_primary_id_seq OWNER TO postgres;

--
-- Name: t_user_ep_values_primary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_user_ep_values_primary_id_seq OWNED BY public.t_user_ep_values.primary_id;


--
-- Name: t_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_user_id_seq OWNER TO postgres;

--
-- Name: t_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_user_id_seq OWNED BY public.t_user.id;


--
-- Name: t_user_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_user_log (
    id integer NOT NULL,
    user_id integer
);


ALTER TABLE public.t_user_log OWNER TO postgres;

--
-- Name: t_user_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_user_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_user_log_id_seq OWNER TO postgres;

--
-- Name: t_user_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_user_log_id_seq OWNED BY public.t_user_log.id;


--
-- Name: t_waste_threatment_cmpny; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_waste_threatment_cmpny (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    phone_num_1 character varying(50),
    fax_num character varying(50),
    address character varying(100),
    description character varying(200),
    email character varying(150),
    postal_code character varying(50),
    active boolean NOT NULL,
    city_id integer,
    country_id integer
);


ALTER TABLE public.t_waste_threatment_cmpny OWNER TO postgres;

--
-- Name: t_waste_threatment_cmpny_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_waste_threatment_cmpny_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_waste_threatment_cmpny_id_seq OWNER TO postgres;

--
-- Name: t_waste_threatment_cmpny_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_waste_threatment_cmpny_id_seq OWNED BY public.t_waste_threatment_cmpny.id;


--
-- Name: t_waste_threatment_tecnology; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_waste_threatment_tecnology (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    active smallint DEFAULT (1)::numeric NOT NULL
);


ALTER TABLE public.t_waste_threatment_tecnology OWNER TO postgres;

--
-- Name: t_waste_threatment_tecnology_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.t_waste_threatment_tecnology_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.t_waste_threatment_tecnology_id_seq OWNER TO postgres;

--
-- Name: t_waste_threatment_tecnology_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.t_waste_threatment_tecnology_id_seq OWNED BY public.t_waste_threatment_tecnology.id;


--
-- Name: world1_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.world1_id_seq
    START WITH 245
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.world1_id_seq OWNER TO postgres;

--
-- Name: industrial_zones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industrial_zones ALTER COLUMN id SET DEFAULT nextval('public.industrial_zones_id_seq'::regclass);


--
-- Name: industrial_zones_clusters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industrial_zones_clusters ALTER COLUMN id SET DEFAULT nextval('public.clusters_id_seq'::regclass);


--
-- Name: industrial_zones_employee id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industrial_zones_employee ALTER COLUMN id SET DEFAULT nextval('public.industrial_zones_employee_id_seq'::regclass);


--
-- Name: t_activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_activity ALTER COLUMN id SET DEFAULT nextval('public.t_activity_id_seq'::regclass);


--
-- Name: t_certificates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_certificates ALTER COLUMN id SET DEFAULT nextval('public.t_certificates_id_seq'::regclass);


--
-- Name: t_cities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cities ALTER COLUMN id SET DEFAULT nextval('public.t_cities_id_seq'::regclass);


--
-- Name: t_clstr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_clstr ALTER COLUMN id SET DEFAULT nextval('public.t_clstr_id_seq'::regclass);


--
-- Name: t_cmpnnt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpnnt ALTER COLUMN id SET DEFAULT nextval('public.t_cmpnnt_id_seq'::regclass);


--
-- Name: t_cmpnt_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpnt_type ALTER COLUMN id SET DEFAULT nextval('public.t_cmpnt_type_id_seq'::regclass);


--
-- Name: t_cmpny id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_id_seq'::regclass);


--
-- Name: t_cmpny_certificates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_certificates ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_certificates_id_seq'::regclass);


--
-- Name: t_cmpny_clstr cmpny_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_clstr ALTER COLUMN cmpny_id SET DEFAULT nextval('public.t_cmpny_clstr_cmpny_id_seq'::regclass);


--
-- Name: t_cmpny_eqpmnt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_eqpmnt ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_eqpmnt_id_seq'::regclass);


--
-- Name: t_cmpny_flow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_flow_id_seq'::regclass);


--
-- Name: t_cmpny_flow_cmpnnt_location id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt_location ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_flow_cmpnnt_location_id_seq'::regclass);


--
-- Name: t_cmpny_flow_cmpnnt_waste_threat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt_waste_threat ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_flow_cmpnnt_waste_threat_id_seq'::regclass);


--
-- Name: t_cmpny_flow_location id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_location ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_flow_location_id_seq'::regclass);


--
-- Name: t_cmpny_grp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_grp ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_grp_id_seq'::regclass);


--
-- Name: t_cmpny_prcss id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prcss ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_prcss_id_seq'::regclass);


--
-- Name: t_cmpny_production_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_production_details ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_production_details_id_seq'::regclass);


--
-- Name: t_cmpny_prsnl key_column; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prsnl ALTER COLUMN key_column SET DEFAULT nextval('public.t_cmpny_prsnl_key_column_seq'::regclass);


--
-- Name: t_cmpny_prsnl_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prsnl_details ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_prsnl_details_id_seq'::regclass);


--
-- Name: t_cmpny_sector id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_sector ALTER COLUMN id SET DEFAULT nextval('public.t_cmpny_sector_id_seq'::regclass);


--
-- Name: t_costbenefit_temp pkey; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_costbenefit_temp ALTER COLUMN pkey SET DEFAULT nextval('public.t_costbenefit_temp_pkey_seq'::regclass);


--
-- Name: t_country id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_country ALTER COLUMN id SET DEFAULT nextval('public.t_country_id_seq'::regclass);


--
-- Name: t_cp_allocation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_allocation ALTER COLUMN id SET DEFAULT nextval('public.t_cp_allocation_id_seq'::regclass);


--
-- Name: t_cp_company_project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_company_project ALTER COLUMN id SET DEFAULT nextval('public.t_cp_company_project_id_seq'::regclass);


--
-- Name: t_cp_is_candidate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_is_candidate ALTER COLUMN id SET DEFAULT nextval('public.t_cp_is_candidate_id_seq'::regclass);


--
-- Name: t_cp_scoping_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_scoping_files ALTER COLUMN id SET DEFAULT nextval('public.t_cp_scoping_files_id_seq'::regclass);


--
-- Name: t_district id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_district ALTER COLUMN id SET DEFAULT nextval('public.t_district_id_seq'::regclass);


--
-- Name: t_doc id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_doc ALTER COLUMN id SET DEFAULT nextval('public.t_doc_id_seq'::regclass);


--
-- Name: t_ecotracking id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_ecotracking ALTER COLUMN id SET DEFAULT nextval('public.t_ecotracking_id_seq'::regclass);


--
-- Name: t_eqpmnt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt ALTER COLUMN id SET DEFAULT nextval('public.t_eqpmnt_id_seq'::regclass);


--
-- Name: t_eqpmnt_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt_type ALTER COLUMN id SET DEFAULT nextval('public.t_eqpmnt_type_id_seq'::regclass);


--
-- Name: t_eqpmnt_type_attrbt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt_type_attrbt ALTER COLUMN id SET DEFAULT nextval('public.t_eqpmnt_type_attrbt_id_seq'::regclass);


--
-- Name: t_flow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow ALTER COLUMN id SET DEFAULT nextval('public.t_flow_id_seq'::regclass);


--
-- Name: t_flow_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_category ALTER COLUMN id SET DEFAULT nextval('public.t_flow_category_id_seq'::regclass);


--
-- Name: t_flow_family id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_family ALTER COLUMN id SET DEFAULT nextval('public.t_flow_family_id_seq'::regclass);


--
-- Name: t_flow_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_log ALTER COLUMN id SET DEFAULT nextval('public.t_flow_log_id_seq'::regclass);


--
-- Name: t_flow_log flow_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_log ALTER COLUMN flow_id SET DEFAULT nextval('public.t_flow_log_flow_id_seq'::regclass);


--
-- Name: t_flow_total_per_cmpny id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_total_per_cmpny ALTER COLUMN id SET DEFAULT nextval('public.t_flow_total_per_cmpny_id_seq1'::regclass);


--
-- Name: t_flow_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_type ALTER COLUMN id SET DEFAULT nextval('public.t_flow_type_id_seq'::regclass);


--
-- Name: t_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_group ALTER COLUMN id SET DEFAULT nextval('public.t_group_id_seq'::regclass);


--
-- Name: t_infrastructure id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_infrastructure ALTER COLUMN id SET DEFAULT nextval('public.t_infrastructure_id_seq'::regclass);


--
-- Name: t_is_prj id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj ALTER COLUMN id SET DEFAULT nextval('public.t_is_prj_id_seq'::regclass);


--
-- Name: t_is_prj_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj_details ALTER COLUMN id SET DEFAULT nextval('public.t_is_prj_details_id_seq'::regclass);


--
-- Name: t_is_prj_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj_history ALTER COLUMN id SET DEFAULT nextval('public.t_is_prj_history_id_seq'::regclass);


--
-- Name: t_is_prj_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj_status ALTER COLUMN id SET DEFAULT nextval('public.t_is_prj_status_id_seq'::regclass);


--
-- Name: t_log_operation_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_log_operation_type ALTER COLUMN id SET DEFAULT nextval('public.t_log_operation_type_id_seq'::regclass);


--
-- Name: t_nace_code id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_nace_code ALTER COLUMN id SET DEFAULT nextval('public.t_nace_code_id_seq'::regclass);


--
-- Name: t_nace_code_rev2 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_nace_code_rev2 ALTER COLUMN id SET DEFAULT nextval('public.t_nace_code_rev2_id_seq'::regclass);


--
-- Name: t_org_ind_reg id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_org_ind_reg ALTER COLUMN id SET DEFAULT nextval('public.t_org_ind_reg_id_seq'::regclass);


--
-- Name: t_prcss id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prcss ALTER COLUMN id SET DEFAULT nextval('public.t_prcss_id_seq'::regclass);


--
-- Name: t_prcss_family id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prcss_family ALTER COLUMN id SET DEFAULT nextval('public.t_prcss_family_id_seq'::regclass);


--
-- Name: t_prdct id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prdct ALTER COLUMN id SET DEFAULT nextval('public.t_prdct_id_seq'::regclass);


--
-- Name: t_prj id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj ALTER COLUMN id SET DEFAULT nextval('public.t_prj_id_seq'::regclass);


--
-- Name: t_prj_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_status ALTER COLUMN id SET DEFAULT nextval('public.t_prj_status_id_seq'::regclass);


--
-- Name: t_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_role ALTER COLUMN id SET DEFAULT nextval('public.t_role_id_seq'::regclass);


--
-- Name: t_sector id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_sector ALTER COLUMN id SET DEFAULT nextval('public.t_sector_id_seq'::regclass);


--
-- Name: t_sector_activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_sector_activity ALTER COLUMN id SET DEFAULT nextval('public.t_sector_activity_id_seq'::regclass);


--
-- Name: t_state id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_state ALTER COLUMN id SET DEFAULT nextval('public.t_state_id_seq'::regclass);


--
-- Name: t_synergy id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_synergy ALTER COLUMN id SET DEFAULT nextval('public.t_synergy_id_seq'::regclass);


--
-- Name: t_transport id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_transport ALTER COLUMN id SET DEFAULT nextval('public.t_transport_id_seq'::regclass);


--
-- Name: t_transportation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_transportation ALTER COLUMN id SET DEFAULT nextval('public.t_transportation_id_seq'::regclass);


--
-- Name: t_unit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_unit ALTER COLUMN id SET DEFAULT nextval('public.t_unit_id_seq'::regclass);


--
-- Name: t_unit_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_unit_type ALTER COLUMN id SET DEFAULT nextval('public.t_unit_type_id_seq'::regclass);


--
-- Name: t_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user ALTER COLUMN id SET DEFAULT nextval('public.t_user_id_seq'::regclass);


--
-- Name: t_user_ep_values primary_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user_ep_values ALTER COLUMN primary_id SET DEFAULT nextval('public.t_user_ep_values_primary_id_seq'::regclass);


--
-- Name: t_user_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user_log ALTER COLUMN id SET DEFAULT nextval('public.t_user_log_id_seq'::regclass);


--
-- Name: t_waste_threatment_cmpny id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_waste_threatment_cmpny ALTER COLUMN id SET DEFAULT nextval('public.t_waste_threatment_cmpny_id_seq'::regclass);


--
-- Name: t_waste_threatment_tecnology id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_waste_threatment_tecnology ALTER COLUMN id SET DEFAULT nextval('public.t_waste_threatment_tecnology_id_seq'::regclass);


--
-- Data for Name: es_definition_of_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.es_definition_of_type (id, project_id, type_id, type_detail_id, description_eng, active, description_tr) FROM stdin;
1	0	0	1	Report Type	1	Rapor Tipleri
2	0	1	1	Company Report	1	Firma Raporlar─▒
3	0	1	2	Project Report	1	Proje Raporlar─▒
4	0	1	3	Product Report	1	├£r├╝n Raporlar─▒
1	0	0	1	Report Type	1	Rapor Tipleri
2	0	1	1	Company Report	1	Firma Raporlar─▒
3	0	1	2	Project Report	1	Proje Raporlar─▒
4	0	1	3	Product Report	1	├£r├╝n Raporlar─▒
\.


--
-- Data for Name: es_project_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.es_project_settings (id, op_project_id, project_name, report_server, report_path, report_image_road, geoserver_road, geoserver_wms, geoserver_wfs) FROM stdin;
1	1	Ecoman	\N	\N	http://88.249.18.205:8090/ecoman/assets/company_pictures/	\N	\N	\N
1	1	Ecoman	\N	\N	http://88.249.18.205:8090/ecoman/assets/company_pictures/	\N	\N	\N
\.


--
-- Data for Name: industrial_zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industrial_zones (id, name) FROM stdin;
4	OST─░M Organize Sanayi B├Âlgesi
5	─░VED─░K Organize Sanayi B├Âlgesi
9	test
\.


--
-- Data for Name: industrial_zones_clusters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industrial_zones_clusters (id, industrial_zone_id, cluster_name) FROM stdin;
3	4	Savunma ve Havac─▒l─▒k
4	4	Rayl─▒ sistemler
5	4	Yenilenebilir Enerji
\.


--
-- Data for Name: industrial_zones_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industrial_zones_departments (id, name) FROM stdin;
6	Natural Gas Sales
7	Electricity
8	Public Relations
\.


--
-- Data for Name: industrial_zones_employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industrial_zones_employee (id, industrial_zone_id, cluster_id, role_id, employee_name) FROM stdin;
4	4	4	1	Vedat Sedat
5	4	3	2	Emre Demir
6	4	4	1	Demir Kan
3	4	5	1	Ahmet ├çabuk
\.


--
-- Data for Name: industrial_zones_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industrial_zones_role (id, name) FROM stdin;
1	Cluster Manager
2	UR-GE Personel
\.


--
-- Data for Name: r_report_attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r_report_attributes (id, parent_id, attr_id, name, report_jasper_id, active, o_date, report_type) FROM stdin;
1	0	1	Flows	1	1	2015-03-26 10:31:47.102+01	0
2	0	2	Components	1	1	2015-03-26 10:31:47.102+01	0
3	0	3	Processes	1	1	2015-03-26 10:31:47.102+01	0
4	0	4	Equipments	1	1	2015-03-26 10:31:47.102+01	0
5	0	5	Product	1	1	2015-03-26 10:31:47.102+01	0
6	1	1	Flow Name	1	1	2015-03-26 10:37:48.72+01	0
7	1	2	Flow Type	1	1	2015-03-26 10:37:48.72+01	0
8	1	3	Flow Family Name	1	1	2015-03-26 10:37:48.72+01	0
9	1	4	Quantity	1	1	2015-03-26 10:37:48.72+01	0
10	1	5	Cost	1	1	2015-03-26 10:37:48.72+01	0
11	1	6	EP	1	1	2015-03-26 10:37:48.72+01	0
12	1	7	Chemical Formula	1	1	2015-03-26 10:37:48.72+01	0
13	1	8	Availability	1	1	2015-03-26 10:37:48.72+01	0
14	1	9	Concentration	1	1	2015-03-26 10:37:48.72+01	0
15	1	10	Pression	1	1	2015-03-26 10:37:48.72+01	0
16	1	11	PH	1	1	2015-03-26 10:37:48.72+01	0
17	1	12	State	1	1	2015-03-26 10:37:48.72+01	0
18	1	13	Quality	1	1	2015-03-26 10:37:48.72+01	0
19	1	14	Output Location	1	1	2015-03-26 10:37:48.72+01	0
20	1	15	Substitue Potential	1	1	2015-03-26 10:37:48.72+01	0
21	1	16	Description	1	1	2015-03-26 10:37:48.72+01	0
22	1	17	Comment	1	1	2015-03-26 10:37:48.72+01	0
\.


--
-- Data for Name: r_report_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r_report_types (id, type_name, active, sort) FROM stdin;
1	Flows	0	1
2	Components	0	2
3	Processes	0	3
4	Equipments	0	4
5	Product	0	5
6	Cost-Benefit-Analysis	0	6
7	Project Consultants	0	7
8	KPI Calculation	0	8
9	CP Potential Identification	0	9
\.


--
-- Data for Name: r_report_used_attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r_report_used_attributes (id, attr_id, report_configurations_id) FROM stdin;
1	6	10
2	7	10
3	6	11
4	7	11
312	1	45
313	2	45
7	1	14
8	10	14
9	1	15
10	11	15
314	3	45
315	4	45
316	5	45
317	1	46
318	2	46
319	3	46
320	4	46
321	5	46
322	1	47
323	2	47
324	3	47
325	4	47
26	1	21
27	10	21
326	5	47
561	1	50
562	2	50
563	3	50
564	4	50
565	5	50
140	1	40
141	10	40
142	11	40
902	1	43
903	6	43
904	9	43
905	10	43
906	11	43
907	13	43
908	21	43
909	19	43
910	2	43
924	1	19
925	6	19
926	7	19
786	1	41
787	6	41
788	7	41
789	12	41
790	13	41
791	17	41
685	1	22
686	13	22
687	14	22
688	15	22
689	16	22
690	17	22
365	1	49
366	2	49
367	3	49
368	4	49
369	5	49
370	1	48
371	2	48
372	3	48
373	4	48
374	5	48
691	18	22
692	19	22
693	20	22
694	21	22
695	11	22
696	12	22
697	10	22
698	8	22
699	6	22
700	22	22
701	9	22
588	1	39
589	18	39
590	2	39
591	5	39
592	4	39
593	3	39
702	7	22
792	21	41
927	8	19
928	10	19
795	1	52
796	6	52
797	7	52
798	8	52
602	1	51
603	6	51
604	7	51
605	8	51
606	9	51
607	10	51
608	11	51
609	12	51
610	13	51
611	14	51
612	16	51
613	17	51
799	9	52
800	10	52
801	11	52
802	12	52
803	2	52
929	16	19
614	18	51
615	19	51
616	20	51
617	21	51
618	22	51
619	2	51
620	3	51
621	4	51
622	5	51
754	1	42
755	6	42
756	7	42
757	8	42
758	9	42
759	16	42
760	17	42
761	13	42
762	21	42
763	19	42
764	2	42
765	3	42
891	1	53
892	8	53
893	9	53
894	10	53
895	11	53
896	12	53
897	13	53
898	15	53
899	21	53
900	14	53
901	2	53
998	1	44
999	20	44
1000	11	44
1001	17	44
1002	12	44
1003	15	44
1004	21	44
1005	16	44
1006	22	44
1007	10	44
1008	18	44
1009	13	44
1010	19	44
1011	8	44
1012	6	44
1013	14	44
1014	9	44
1015	7	44
1016	2	44
1017	3	44
1018	4	44
1019	5	44
1020	1	54
1021	2	54
1022	3	54
1023	4	54
1024	5	54
1030	1	55
1031	6	55
1032	7	55
1033	8	55
1034	9	55
1035	3	55
1046	1	56
1047	2	56
1048	3	56
1049	4	56
1050	5	56
1087	1	57
1088	2	57
1089	3	57
1090	4	57
1091	5	57
1092	1	58
1093	3	58
1094	1	59
1095	2	59
1096	3	59
1097	4	59
1098	5	59
1099	1	60
1101	1	61
1102	1	34
1103	20	34
1104	11	34
1105	12	34
1106	10	34
1107	13	34
1108	21	34
1109	8	34
1110	6	34
1111	22	34
1112	14	34
1113	7	34
1114	15	34
1115	18	34
1116	19	34
1117	9	34
1118	5	34
1119	2	34
1120	4	34
1121	3	34
1122	1	62
1123	9	62
1124	10	62
1125	12	62
\.


--
-- Data for Name: r_report_used_configurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.r_report_used_configurations (id, project_id, user_id, report_jasper_id, report_type_id, r_date, report_name, company_id) FROM stdin;
19	1	35	1	1	2015-04-02 12:17:38.909+02	dene22	9
1	1	8	1	1	\N	test	-99
2	1	8	1	1	\N	test2	-99
10	1	8	1	1	\N	test4	-99
11	1	8	1	1	2015-04-01 16:49:51.548+02	asdasdasd	-99
13	1	8	1	1	2015-04-01 16:54:20.963+02	asdasdasd1	-99
14	1	8	1	1	2015-04-02 08:58:12.087+02	ssss	-99
15	1	8	1	1	2015-04-02 09:04:39.214+02	gg	-99
44	1	35	0	1	2015-04-21 11:29:41.244+02	Test Report Paper Production 2	94
21	1	8	1	1	2015-04-02 12:48:34.385+02	a	41
25	1	8	0	1	2015-04-04 22:02:53.083+02	s	-1
45	1	35	0	1	2015-04-21 13:00:27.284+02	test Report Paper Production 3	94
46	1	35	0	1	2015-04-21 13:02:02.596+02	test Report Paper Production 4	94
47	1	35	0	1	2015-04-21 13:02:27.46+02	test neu	94
49	1	35	0	1	2015-04-29 14:15:05.333+02	Test Catherine 2	96
48	1	35	0	1	2015-04-21 13:02:40.715+02	test neu 2	94
40	1	8	0	1	2015-04-06 15:18:43.105+02	zz4	9
50	1	35	0	1	2015-05-07 10:07:07.502+02	Test report paper production 5	94
39	1	8	0	1	2015-04-06 11:43:53.693+02	test_06_04_6666_upd_testtt	41
51	1	35	0	1	2015-05-07 10:08:06.832+02	test catherine 1	94
22	1	8	0	1	2015-04-02 12:56:44.963+02	zz	9
42	1	35	0	1	2015-04-06 16:42:25.855+02	test_zeynel_late_afternoon	9
41	1	35	0	1	2015-04-06 15:19:10.061+02	zz3	9
52	1	35	0	1	2015-05-07 16:28:33.747+02	test catherine 5	97
53	1	8	0	1	2015-05-07 16:30:41.72+02	Test catherine 6	96
43	1	35	0	1	2015-04-21 11:20:36.328+02	Test Report Paper Production 1	78
54	1	8	0	1	2016-01-13 09:01:16.159+01	xyz	132
55	1	8	0	1	2016-03-08 08:30:48.611+01	test_design	132
56	1	8	0	1	2016-03-22 15:39:29.503+01	test report2	131
57	1	28	0	1	2016-04-02 07:37:31.783+02	test Dirk	134
58	1	28	0	1	2016-05-02 13:10:18.682+02	Machining company	3388
59	1	48205	0	1	2016-05-17 17:54:04.018+02	Dirbtinis pluostas	3394
60	1	8	0	1	2016-05-30 16:03:30.826+02	aaa	132
61	1	8	0	1	2016-05-30 16:03:53.076+02	aaaz	132
34	1	8	0	1	2015-04-06 11:35:12.832+02	Dizayn Makina Raporu	132
62	1	48203	0	1	2016-07-30 19:02:23.022+02	h41	3383
\.


--
-- Data for Name: t_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_activity (id, name, international_code, active) FROM stdin;
1	zeyn dag	12	1
4	zeyn dag	12	1
5	zeyn dag new	25	1
3	zeyn zeyn oldu ┼şimdik	12	1
\.


--
-- Data for Name: t_certificates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_certificates (id, name, description) FROM stdin;
1	ISO 9000	Kalite Y├Ânetimi
2	ISO 14000	├çevre Y├Ânetimi
3	ISO 20121	S├╝rd├╝r├╝lebilir Vakalar
4	ISO 22000	G─▒da G├╝venli─şi Y├Ântemi
5	ISO 26000	Sosyal Sorumluluk
6	ISO 27001	Bilgi G├╝venli─şi
7	ISO 31000	Risk Y├Ânetimi
8	ISO 50001	Enerji Y├Ânetimi
9	ISO 13485	Metal Tibbi Malzeme Standart─▒
10	CE	Avrupa Toplulu─şu Uyumlulu─şu
11	OHSAS	─░┼şyeri Sa─şl─▒─ş─▒ ve G├╝venli─şi Y├Ânetimi
12	Tesis G├╝venlik Belgesi	
13	AS 9100	Havac─▒l─▒kta Kalite Y├Ânetimi
14	GOST Belgesi	
15	TSI Sertifikas─▒	
16	IRIS Sertifikas─▒	
17	FDA(Medikal)	ABD'ye giri┼ş belgesi(Medikal)
18	ANYISA	Brezilya'ya giri┼ş belgesi
19	SFDA ve CCC	├çin'e giri┼ş belgesi
\.


--
-- Data for Name: t_cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cities (id, name) FROM stdin;
1	Adana
2	Ad─▒yaman
3	Afyon
4	A─şr─▒
5	Amasya
6	Ankara
7	Antalya
8	Artvin
9	Ayd─▒n
10	Bal─▒kesir
11	Bilecik
12	Bing├Âl
13	Bitlis
14	Bolu
15	Burdur
16	Bursa
17	├çanakkale
18	├çank─▒r─▒
19	├çorum
20	Denizli
21	Diyarbak─▒r
22	Edirne
23	Elaz─▒─ş
24	Erzincan
25	Erzurum
26	Eski┼şehir
27	Gaziantep
28	Giresun
29	G├╝m├╝┼şhane
30	Hakkari
31	Hatay
32	Isparta
33	Mersin(i├ğel)
34	─░stanbul
35	─░zmir
36	Kars
37	Kastamonu
38	Kayseri
39	K─▒rklareli
40	K─▒r┼şehir
41	Kocaeli(izmit)
42	Konya
43	K├╝tahya
44	Malatya
45	Manisa
46	Kahramanmara┼ş
47	Mardin
48	Mu─şla
49	Mu┼ş
50	Nev┼şehir
51	Ni─şde
52	119-TRIAL-Ordu 25
53	176-TRIAL-Rize 94
54	158-TRIAL-Sakarya 202
55	271-TRIAL-Samsun 266
56	178-TRIAL-Siirt 93
57	151-TRIAL-Sinop 284
58	118-TRIAL-Sivas 264
59	119-TRIAL-Tekirda─ş 52
60	100-TRIAL-Tokat 87
61	160-TRIAL-Trabzon 126
62	10-TRIAL-Tunceli 257
63	70-TRIAL-┼Şanl─▒urfa 215
64	276-TRIAL-U┼şak 227
65	43-TRIAL-Van 258
66	264-TRIAL-Yozgat 9
67	82-TRIAL-Zonguldak 286
68	165-TRIAL-Aksaray 187
69	177-TRIAL-Bayburt 74
70	225-TRIAL-Karaman 127
71	229-TRIAL-K─▒r─▒kkale 128
72	223-TRIAL-Batman 20
73	2-TRIAL-┼Ş─▒rnak 262
74	123-TRIAL-Bart─▒n 296
75	137-TRIAL-Ardahan 61
76	295-TRIAL-I─şd─▒r 125
77	64-TRIAL-Yalova 160
78	202-TRIAL-Karab├╝k 16
79	230-TRIAL-Kilis 226
80	211-TRIAL-Osmaniye 171
81	111-TRIAL-D├╝zce 47
\.


--
-- Data for Name: t_clstr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_clstr (id, name, active, org_ind_reg_id) FROM stdin;
4	Medikal K├╝mesi	1	1
5	─░┼ş ve ─░n┼şaat K├╝mesi	1	2
6	Savunma ve Havac─▒l─▒k K├╝mesi	1	3
9	Kau├ğuk Teknolojileri K├╝melenmesi	1	3
\.


--
-- Data for Name: t_cmpnnt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpnnt (id, name, name_tr, active, cmpnt_type_id, cmpny_id) FROM stdin;
103	Water distribution system	Water distribution system	1	\N	3403
102	Gas boiler	Gas boiler	1	\N	3403
104	Water distribution system	Water distribution system	1	\N	3403
105	caustic_soda	caustic_soda	1	\N	3446
108	electricity	electricity	1	\N	3446
111	rawmilk_losses	rawmilk_losses	1	\N	3446
112	electricity	electricity	1	\N	3446
99	test	test	1	\N	135
101	Cooling unit	Cooling unit	1	\N	3404
100	Cooling unit	Cooling unit	1	\N	3404
\.


--
-- Data for Name: t_cmpnt_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpnt_type (id, name, active) FROM stdin;
1	test	1
\.


--
-- Data for Name: t_cmpny; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny (id, name, phone_num_1, phone_num_2, fax_num, address, description, email, postal_code, logo, active, latitude, longitude, site, city_id, country_id, turnover, turnover_unit_id, infrastructure_id, surface_turnover, surfaceturnover_unit, quickwins, quickwins_unit, upperlimit_investments, upperlimit_investments_unit, transportation_id, comments, industrial_zone_id, cluster_id) FROM stdin;
3356	kessie zimmerman	\N	+558-82-9716835	+942-54-1760077	Laborum. Minus pariatur? Quia vel quia optio, autem eveniet, consequatur deleniti archite	Laborum. Minus pariatur? Quia vel quia optio, autem eveniet, consequatur deleniti architecto tempore, esse quo.	kyny@hotmail.com	\N	default.jpg	t	39.984551947010985	32.73284196853638	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3357	demetria austin	\N	+844-68-6925744	+676-55-4571940	Ullam quia eum dolorem duis pariatur? Enim tempor blanditiis et odit sint. test	.Ullam quia eum dolorem duis pariatur? Enim tempor blanditiis et odit sint.	cihusuwu@yahoo.com	\N	default.jpg	t	39.99832832411268	32.73309946060181	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3403	bg test	\N	+41584241111		Av. de Cour 61\r\n1007 Lausanne	Consulting and engineering	alexandre.epp@bg-21.com	\N	default.jpg	t	46.51506185310115	6.618090569972992	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3404	industry x lausanne	\N	16544654		Av. de Cour 1111	Meat preservation and production	industry@lausanne.ch	\N	default.jpg	t	46.51457696519457	6.618964601511607	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3372	piasio	\N	022 706 25 00	0	Chemin du Champ-des-Filles 4, 1228 Plan-les-Ouates, Suisse	Construction business	aa	\N	default.jpg	t	46.1670665638922	6.1083984375	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3378	ferme des grand bois	\N	+41 22 341 05 19	+41 22 341 05 27	Nathalie et Marc Zeller\r\n82, route de Peney\r\n1214 Vernier / Gen├¿ve\r\nSuisse	agriculture	contact@ferme-des-grands-bois.ch	\N	default.jpg	t	46.2067005720145	6.060590744018555	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3382	food industry	\N	0000000	0000000	street country	aaaa	aaaa@gmail.com	\N	default.jpg	t	39.97346964672725	32.74367809295654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3406	aquaculture business can tho	\N	07103.843981	07103.843987	Lot 16A3, Tra Noc 1 Industrial zone, Binh Thuy District, Can Tho City	Food processing (fish feeds)	ngoccangct@cp.com.vn	NULL	default.jpg	t	10.071986560661513	105.74133505975476	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3373	holcim	\N	058 850 05 00	00	Chemin de la Vieille-Ecole 12\r\n1242 Satigny, Suisse	Cimentery	aa	\N	default.jpg	t	46.19892606263688	6.04647159576416	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3407	mekong river orchards joint-stock company	\N	0710.3842810		Lot. 17E1, Road No.5, Tra Noc I Industrial Zone, Tra Noc Wards, Binh Thuy District, Can Tho City	Fruit products and beverages\r\nWeb: http://www.vergersmekong.com	info@vergersmekong.com	\N	default.jpg	t	10.0676986363842	105.74667229068518	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
8	reddit	1-222-111-11-11	1-222-111-11-12	1-222-111-11-10	San Francisco, Silicon Alley	Reddit Conde Nast Digital ┼şirketine ait bir sosyal haber sitesidir.	contact@reddit.com	NULL	8.jpg	t	44.08758502824516	-107.578125	\N	\N	229	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N		0	0
3405	nam hung phat packaging manufacturing and trading limited liability company	\N	(710) 3844 836 		Lot 8 B1 Tranoc I Industrial Zone, Tra Noc ward, Binh Thuy District, Can Tho	Paper	ctynamhungphat@gmail.com	NULL	default.jpg	t	9.977344575762045	105.66474540630645	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3376	le porc de a a z	\N	+33 4 50 03 25 98	00	9 Rue de Fernollet\r\n74800 Saint-Pierre-en-Faucigny\r\nFrance	Porc breeding	aa	\N	default.jpg	t	46.083047076616886	6.346825361251831	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
65	fine chemestry	000	0000000	0000000	test	test	emily.vuylsteke@sofiesonline.com	NULL	default.jpg	t	46.20686392144151	6.080503463745117	\N	\N	221	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3375	graviere d epeisses	\N	022 989 15 90	00	Route de Satigny 6, 1217 Meyrin, Suisse	gravel	aa	\N	default.jpg	t	46.22015299722909	6.071019172668457	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3414	test 1	\N	0000000		xxx	dummy run	xxx@xxx.vn	\N	default.jpg	t	10.030797567971211	105.76843957200322	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3374	firmenich	\N	022 780 22 11	00	Route des Jeunes 1, 1227 Les Acacias, Suisse	FIne Chemistry	aa	\N	default.jpg	t	46.19759678615262	6.128482818603516	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
66	givaudan	000	+41 78 625 27 51	+41 78 625 27 51	Chemin de la Parfumerie 5, 1214 Vernier, suisse	fine chemestry	emily.vuylsteke@sofiesonline.com	NULL	default.jpg	t	46.20662632211438	6.078615188598633	\N	\N	221	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
139	icast	123456	123456	123456	Vuache 1	blabla	guilma@gmail.com	NULL	default.jpg	t	46.20757671325672	6.142215728759766	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3417	detergents company	\N	123456	123456	Frenkendorf	Produces detergents and soaps	thiscompanysemail@mail.com	\N	default.jpg	t	47.51180220858484	7.719815969467163	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
67	lem	00	00	00	test	test	emily.vuylsteke@sofiesonline.com	\N	default.jpg	t	46.22260258751591	6.0706329345703125	\N	\N	221	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3418	milk factory	\N	004112345678	004112345678	Milkstreet 10\r\nMilktown 0000	Milkproducts	anonymous@anonymous.com	\N	default.jpg	t	46.40354866416617	8.461327052116417	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3423	case_printingcompany	\N	00 00 00 00 00	00 00 00 00 01	Offset\r\nPrintstrasse3\r\n1888 Press	Offset printing company	offset@print.ch	NULL	default.jpg	t	47.06611993256573	8.615360951423668	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3434	cow farm ghbh	\N	092 309 12 13		Jonasstrasse 5	Description	info@cow-farm.ch	NULL	default.jpg	t	47.14990311233897	8.654687500000023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3430	milk_processing_ company	\N	XY	XY	XY-Adress	XY_Milk_Company	giovanni.desiderio@students.fhnw.ch	\N	default.jpg	t	47.52630443985739	7.647863370303753	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3425	cow_farm_gmbh	\N	838054	838545	Pilatusstrasse 5	We are the cow farm company.	info@cowfarm.ch	NULL	default.jpg	t	47.03022288846071	8.231128328288946	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3442	ceosparrii_cow_farm	\N	777777777	777777777	XY	XY	CEOSPARRII_Cow_Farm@fhnw.ch	\N	default.jpg	t	46.167445378161695	6.008777347860814	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3447	a&d consulting	\N	123		Consulting road\r\nMuttenz	consulting	dominic.renfer@students.fhnw.ch	\N	default.jpg	t	47.53466019858155	7.642542394974798	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3422	cow farm	\N	0041234	0041234	Address	Description	cowfarm@cowfarm.com	NULL	default.jpg	t	47.51014269144338	7.658794021606434	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3448	space clinker	\N	00123123123		Siggenthal	The largest clinker production plant	space.clinker@dontmailme.com	NULL	3448.jpg	t	47.508568253833765	8.238015056263807	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3444	testa & co	\N	123456		Muttenz	Brewery since 2020	testaco@omg.om	NULL	3444.jpg	t	47.534807585819316	7.642001007293153	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3457	yves brauerei	\N	+41795656875		Rheingasse 45\r\n4058 Basel	Bierbrauerei	yves.saladin@students.fhnw.ch	NULL	default.jpg	t	47.55932722381996	7.593248642538861	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3455	brauerei pn	\N	0612651588		Baslerstrasse 25\r\n4051 Basel	Brauerei Leckerbier	leckerbier@bluewin.ch	NULL	default.jpg	t	47.55739582447537	7.583758604617081	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3462	bier vor vier brauerei	\N	0792315390		Rheingasse 45\r\n4058 Basel	Bier Herstellung	joel.trummer@students.fhnw.ch	NULL	default.jpg	t	47.559422329537426	7.59326311465033	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3408	tri-viet international, co. ltd	\N	(710) 3663399		Lot 2.8 A Tranoc II Industrial Zone, Phuoc Thoi ward, Omon District, Can Tho	Baseball glove manufacturing	xxx@xxx.vn	\N	default.jpg	t	10.013846492740582	105.77187100750598	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3364	terrabloc sarl	\N	+ 41 79 412 74 15	0000	5b route des Jeunes - 1227 les Acacias - Suisse	description	info@terrabloc.ch	\N	default.jpg	t	46.19210111193638	6.128139495849609	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
136	serbeco	+41 78 625 27 51	+41 22 338 15 24	+41 22 338 15 30	EcoParc Bois de Bay	Recyclage de bois et de m├®taux	serbeco@serbeco.ch	NULL	default.jpg	t	46.19756708128284	6.065483093261719	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3413	can tho dairy factory ÔÇô vinamilk	\N	(+84. 0292) 6 258 555		block 46, Tra Noc I Industrial Park, Tra Noc Ward, Binh Thuy District, Can Tho City	Dairy production	xxx@xxx.vn	\N	default.jpg	t	10.039506362914867	105.75680585620898	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3415	test2	\N	0000000		xx	dummy run	xxx@xxx.vn	\N	default.jpg	t	10.024639044912838	105.74775294922506	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3416	margarine company	\N	123456	123456	Frenkendorf	Produces margarine and butter	thiscompanysemail@mail.com	\N	default.jpg	t	47.511798556489985	7.719821333885193	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3474	space klinker cement	\N	061 228 55 55		Hofackerstrasse 30, 4132 Muttenz	Production of cement	fabio.darocharibeiro@students.fhnw.ch	\N	default.jpg	t	47.51688131318915	7.603153450137725	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3424	test_metalsheetcompany	\N	0909090909	0808080808	Sheet\r\nAluminiumstrasse 4\r\n1888 Press	Metal sheet cutting company	metal@sheet.ch	\N	default.jpg	t	47.387209054916354	8.546446746059587	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
99	geneva 2	+41786252751	+41223381524	+41 22 3881520	Route de Plan-les-Ouates 89	Wood processus	guillaume.massard@sofiesonline.com	\N	default.jpg	t	46.16758668526399	6.107969284057617	\N	\N	221	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
98	geneva 1	+41786252751	+41223381524	+41 22 3881520	Route de Meyrin 100	Metal production	guillaume.massard@sofiesonline.com	\N	default.jpg	t	46.22105861606872	6.086640357971191	\N	\N	221	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3478	hard rock	\N	1029384756	1029384756	Kiev	Producer of concrete panels, conrete mixtures	a.vorfolomeiev@recpc.org	\N	default.jpg	t	50.466019798795976	30.456645044115323	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3419	milk processing	\N	0041612285598	0041612285598	Milkstreet 5\r\nMilktown 1234	Medium size milk processing	dirk.hengevoss@fhnw.ch	NULL	3419.jpg	t	47.53469668051734	7.642171382904053	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3426	milk processing company	\N	123123	1454547	Industriestrasse 1, Basel	Milk processing	milk.company@gmail.com	NULL	default.jpg	t	46.75611253677378	7.4686968696868234	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3433	milk_processing_company	\N	XY	XY	XY	XY	XY	\N	default.jpg	t	47.52716598423039	7.647249952363836	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3439	milk	\N	03736484949	03839303030	erer	rer3	livia.engel@students.fhnw.ch	\N	default.jpg	t	47.14990311233897	7.951562500000023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3443	ceosparrii_milk_production	\N	77777777	777777777	XY	XY	CEOSPARRII_Milk_production@fhnw.ch	\N	default.jpg	t	46.22389414140932	6.201989746093773	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3446	milk factory laughing cow	\N	0411236688		Milchstrasse 12\r\n2020 Wisenstadt	Processing of milk and milk products	valentina.lombardo@students.fhnw.ch	\N	default.jpg	t	47.407792314664796	7.619775256514538	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3481	alupro	\N	0987612345	0987612345	Kiev	Aluminium Manufacturing and Processing	maxmuster@alupro.com	\N	default.jpg	t	50.39488607952807	30.490577658032553	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3458	dominic brauerei	\N	0041787923411		Musterstrasse 1Basel	Brauerei	dominic.jaggi@students.fhnw.ch	\N	default.jpg	t	47.55183925004349	7.594506835937489	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3456	stefan.l brauerei	\N	0792506791		Rheingasse 45\r\nBasel	Brauerei zur Herstellung verschiedenster Biersorten	stefan.lehmann@students.fhnw.ch	NULL	default.jpg	t	47.5592934541445	7.593172788619995	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3466	nachbarschaft	\N	079xxxxxxxx		Strasse 11 Basel	Wohnhaus in der Nachbarschaft	bla.bla@bla.ch	NULL	default.jpg	t	47.54625630471831	7.574219004771816	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3492	brauerei_rohrbach	\N	148713	1432	Bliblablu	Biologische Bierherstellung	rina.rohrbach@students.fhnw.ch	\N	default.jpg	t	46.777375227442505	7.36573275853202	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3496	brewcrew	\N	076 379 8558		Pfeffingerring 120\r\nAesch 4147\r\nSchweiz	Brewing Beer	alessia.baertsch@students.fhnw.ch	NULL	default.jpg	t	47.47526850537029	7.5883977208058395	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3409	tay do steel company ltd.	\N	(84.71) 3841822 - 3743707		Lot 45, Road No. 2, Tra Noc Industrial Zone 1, Binh Thuy District, Can Tho City	Steel manufacturing\r\nWebsite: http://www.theptaydo.com/	xxx@xxx.vn	\N	default.jpg	t	10.05411086723928	105.76476067349915	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
137	tuilerie	+41 78 625 27 51	+41 22 338 15 24	+41 22 338 15 30	Bardonnex, Gen├¿ve	Extraction d'argile et fabrication de tuiles	tuilerie@tuilerie.ch	NULL	default.jpg	t	46.1471347810282	6.098227500915527	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
138	probeton	+41 78 625 27 51	+41 22 338 15 24	+41 22 338 15 30	Meyrin, Gen├¿ve	Centrale ├á b├®ton et gravi├¿re	pro@probeton.ch	NULL	default.jpg	t	46.21945521514774	6.069602966308594	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3366	patek philippe	\N	+41 22 884 20 20	ee	Chemin du Pont-du-Centenaire 141\r\n1228 Plan-les-Ouates\r\nSuisse	Watch	ee	\N	default.jpg	t	46.167980488174	6.111359596252441	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3365	lrg	\N	(+41) 0 22-884-8200	(+41) 0 22-884-8179	Chemin des Aulx 6, 1228 Plan-les-Ouates / Gen├¿ve, Suisse	Laiteries R├®unies Genevoise	info@lrgg.ch	NULL	default.jpg	t	46.16862691325355	6.105834245681763	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
125	cruz newman	123123123123	+582-90-8431792	+339-46-4664312	Id aute eius laudantium, consequatur? Ad accusamus odio voluptatem id impedit, sint, quia eum sit a	.Id aute eius laudantium, consequatur? Ad accusamus odio voluptatem id impedit, sint, quia eum sit .Id aute eius laudantium, consequatur? Ad accusamus odio voluptatem id impedit, sint, quia eum sit .	bynar@hotmail.com	NULL	default.jpg	t	39.97669257813978	32.741124629974365	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3367	rolex	\N	022 302 22 00	00	Chemin du Pont-du-Centenaire 113, Gen├¿ve, Suisse	watch	aa	\N	default.jpg	t	46.16922132041529	6.110351085662842	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3368	blondin & janin	\N	00	00	plaine de l'Aire	Fruit and Vegetables Producer	aa	\N	default.jpg	t	46.16131517975305	6.084194183349609	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3369	biogaz mandement	\N	F. +41 22 341 05 27	00	Biogaz Mandement\r\nRoute de Peney 82\r\n1214 Vernier	aa	contact@ferme-des-grands-bois.ch	\N	default.jpg	t	46.20677482181426	6.061062812805176	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3370	milo & cie	\N	022 341 33 40	0	Route de la Garenne 33\r\n1214 Vernier	Greenhouses	a	\N	default.jpg	t	46.208289495822626	6.06395959854126	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3371	abb bis	\N	+41 58 586 22 11	0000000	rue des Sabli├¿res 4-6 \r\nZI de Meyrin-Satigny \r\nCase postale 2095 \r\nGen├¿ve	Machinery and equipment production	emily.vuylsteke@sofiesonline.com	NULL	default.jpg	t	46.217243038867565	6.060343980789185	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3412	can tho fertilizer & chemical jsc	\N	0000000		Tra Noc 1 Industrial Park, Binh Thuy district, Can Tho city	Fertilizer & chemical production	xxx@xxx.vn	\N	default.jpg	t	10.059557305442587	105.73757086233081	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3420	sofiescompanytest1	\N	00090099999		SofiesCompanyTest1\r\nTestRoad1\r\nTest1	Forestry company	SofiesCompanyTest1@test1.ch	\N	default.jpg	t	46.832287735682776	9.561059570312523	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3427	cattle-farm	\N	0797654321		Beispielstrasse 12\r\n3456 Beispielstadt	produces milk	cattle.farm.beispielstadt@gmail.com	\N	default.jpg	t	47.511126906413324	7.711115607665079	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3389	kauno alus	\N	x	x	Savanori┼│ pr. 7, LT-44255 Kaunas	AB ÔÇŞKauno alusÔÇ£ producing non alcoholic soft drinks and beer.	x	\N	default.jpg	t	54.89893336972299	23.901877999305725	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3440	muh muh cow farm	\N	213213	321432	Cowstreet 1	Cow farm	cow@farm.ch	\N	default.jpg	t	47.68763095490857	7.391259765625023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3388	machining company	\N	+41614674589	+41614674589	9015 St. Gallen	Manufacturing of machines	dirk.hengevoss@fhnw.ch	NULL	3388.jpg	t	47.4057852900587	9.30241584777832	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
134	printing company	+41614674471	+41614674589	+41614674701	CH-9001 St. Gallen	News paper printing company (Nace code 22.21)	dirk.hengevoss@fhnw.ch	NULL	default.jpg	t	47.40613383101032	9.303274154663086	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3485	p.hilippe consulting	\N	1	2	3	Consutling Firm	philippe.langer@students.fhnw.ch	\N	default.jpg	t	13.715313057884165	-84.40295522598278	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3459	josip bierbrauerei	\N	x		Hofackerstrasse 30	Bierbrauerei	x	\N	default.jpg	t	47.53470392402197	7.642149925231934	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3467	bierpharmaceuticals	\N	0784444444		Bierabfallnachhaltignutzenstrasse 39	Aus dem Filtrationsr├╝ckstand vom Bier k├Ânnen Pharmzeutische Produkte isloiert werden, zudem dient es auch als Energiequelle f├╝r Bakterien in den Bioreaktoren	bier.pillen@pillenbier.ch	\N	default.jpg	t	47.56637743983566	7.6025390625	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3500	bierbrauerei m. ehrli mit uns griegsch meh	\N	+41791744452		sch├Âllenenstrasse 31	Bier Bier Bier	micha.wehrli@students.fhnw.ch	\N	default.jpg	t	47.394655269795805	7.805076336860646	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3471	milkcorp	\N	2232	12312	Basel	raw Milk refining	blubb@test.de	\N	default.jpg	t	47.51669801692316	7.584234654478612	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3475	ukraine	\N	+00	+00	x	test	x@y.com	\N	default.jpg	t	48.85510104429023	28.342187499999987	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3480	uav x	\N	1234509876	1234509876	Kiev	Unmanned aerial vehicles production for civil and military	m.kuznietsova@golocal-ukraine.com	\N	default.jpg	t	50.43096079072675	30.520825804538173	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3489	held ltd. bierbrauen und trinken	\N	2222222222		Gaggi strass 3 \r\n4059 Basilea	We drink and produce Beer!\r\nMainly drink	samuel.held@stu.e.ch	NULL	default.jpg	t	47.55922529753446	7.59335150334981	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3493	dominiksbierbrauerei	\N	+491622534182		1 Leimgrubenstra├şe	Best Beer in Town	dominik.janik@students.fhnw.ch	\N	default.jpg	t	47.55354884531818	7.587632799424164	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3498	biervor4	\N	0792387724		Pfeffingerring 120 \r\n4147	Beer Production Company	benjamin.buehlmann@students.fhnw.ch	\N	default.jpg	t	47.47593353529221	7.590215301513661	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3410	hanoi-cantho seafood jsc	\N	+84 292 625 1400		Slot 2.17, Tranoc 2 Industrial Zone, Phuoc Thoi ward, O Mon district, Can Tho city	Seafood processing\r\nWebsite: http://www.hacaseafood.com.vn	vundh@hacaseafood.com	\N	default.jpg	t	10.051607294723533	105.76334591294312	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3421	sofiescompanytest2	\N	080888088080808		TestRoad2\r\nTest2	Wood construction	SofiesCompanyTest2@test2.ch	\N	default.jpg	t	47.064783238998714	8.803002929687523	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3432	milkprocessingcompanyandy	\N	0764539295		fantasystreet 404	milk processing	andreas.portmann1@students.fhnw.ch	\N	default.jpg	t	46.488332325004265	7.687890625000023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3436	milkprocessingcompany	\N	XY	XY	XY	XY	XY	\N	default.jpg	t	47.527609124861534	7.649025416374229	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3460	brauerei mp	\N	+41790009990		Basel	Bierbrauerei	bierlibrau@gmail.com	\N	default.jpg	t	47.55949846219578	7.593147627114316	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3472	hotel sleepless 2021	\N	09005767676		Z├╝rich, Hauptsrtrasse	Hotel from zurich 2021	hotelsleepless@2021.com	\N	default.jpg	t	47.37745627767961	8.56550360887268	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3476	parquet +	\N	1234567890	1234567890	Kiev	Oak Parquet Producer	omelchukivan@gmail.com	\N	default.jpg	t	50.49726861686494	30.514168980617722	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3483	3d industries	\N	123456789	123456789	Ukraine	Additive manufacturing	vasyl123@email.com	\N	default.jpg	t	49.544780724966664	25.635772552425824	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3490	lospolloshermanos	\N	0190666666		Mein Schtreet 1	mejores pollos en el mundo	emanuel.schneiter@students.fhnw.ch	\N	3490.jpg	t	19.19398256651658	-81.59947285220439	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3486	clementespengales	\N	080808	ke faxe	44 Arrawarra Beach Road\r\nArrawarra, NSW 2456	Take it easy but take it	clement.schuepbach@students.fhnw.ch	NULL	default.jpg	t	-30.06454326858282	153.20116711594298	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3494	bj├Ârnssaufgeselschaft	\N	0799379654		Wartenbergstrasse 50	Saufi Saufi	bjoern.ramaswamy@students.fhnw.ch	\N	default.jpg	t	47.54840820954936	7.5857464978575395	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3497	textil-industry	\N	+41 79 872 60 81		Pfeffingerring 120\r\n4147 Aesch	Textil	yanick.f@hotmail.com	\N	default.jpg	t	47.47548734487079	7.588772639716357	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3411	cameco ÔÇô mitagas factor	\N	07103.890306		Milestone no.10, Highway 91, Industrial Zone Tra Noc 1, Tra Noc Ward, Binh Thuy District, Can Tho	Gas production	hoanganhtitagas@gmail.com	NULL	default.jpg	t	10.054440968195053	105.76087054721575	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
131	dizayn makina	90 312 354 25 04	90 312 354 24 41	90 312 354 26 15	Ahi Evran Cad. 36. Sok. No:1 Ostim 06370 Yenimahalle / Ankara - Turkey	1987 y─▒l─▒nda Ostim Sanayi Sitesinde tala┼şl─▒ imalat sekt├Âr├╝ndeki hizmetlerine ba┼şlayan firmam─▒z, 1990 y─▒l─▒ndan bu yana savunma sanayine alt y├╝klenici olarak ├ğal─▒┼şmaktad─▒r. test	info@dizaynmakina.com.tr	NULL	default.jpg	t	39.976232168671984	32.74970769882202	\N	\N	91	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3390	glas manufacturing	\N	061 467 4589	061 467 4589	xx	Safety and Insultation glass manufacturar	dirk.hengevoss@fhnw.ch	NULL	3390.jpg	t	47.40699069747708	9.29966188967228	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3429	muh muh farm (cow farm)	\N	1245	14567	Farmwille 3	Cow farm	muh.cow@gmail.com	\N	default.jpg	t	46.970281918533956	7.687890625000023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3394	dirbtinis pluostas	\N	+370 37 300 323	+370 37 300 323	Pramon─ùs pr. 4, Kaunas, Lithuania	Acetate yarn diversity	dainiote@gmail.com	NULL	default.jpg	t	54.914514007665275	23.913574442267418	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3437	milkprocessandy	\N	07644444444		xxx	xxx	andreas.portmann1@students.fhnw.ch	\N	default.jpg	t	46.79005545957665	8.039453125000023	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
135	abb	+41 78 625 27 51	+41 22 338 15 24	+41 22 338 15 30	1227 Carouge	Metal and machine industry	abb@abb.ch	NULL	default.jpg	t	46.17987497927316	6.1418616771698	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3461	brauerei claudia	\N	001234	002345	xxxxxx	xxxx	claudia.steiner@students.fhnw.ch	NULL	default.jpg	t	46.32672699517508	8.22255412340163	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3477	ventprom	\N	0987654321	0987654321	Kiev	Production of ventilation aquipment: air ducts, air diffusers, other ventilation aquipent	elladmitrochenkova@recpc.org	\N	default.jpg	t	50.48102913472966	30.46393992734612	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3479	lislis toys	\N	0864213579	0864213579	Kiev	Wooden Toys Producer	v.popovych@recpc.org	\N	default.jpg	t	50.45235286523006	30.506085041486863	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3491	gm├╝esli ag	\N	03112	03112	Gm├╝etlib├ñrg 1	Herstellung von Granola M├╝esli mit getrocknetem Gem├╝se aus der Region	nike.maglaras@students.fhnw.ch	NULL	default.jpg	t	47.34969697252021	8.491160273551941	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
3495	stainz	\N	0763374106		Pfeffingerring 120 4147 Aesch	coloring textiles	donna.karedan@students.fhnw.ch	NULL	default.jpg	t	47.475824926745624	7.588363250896113	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
\.


--
-- Data for Name: t_cmpny_certificates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_certificates (id, cmpny_id, date, certificate_id, active) FROM stdin;
\.


--
-- Data for Name: t_cmpny_clstr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_clstr (cmpny_id, clstr_id) FROM stdin;
135	4
135	9
\.


--
-- Data for Name: t_cmpny_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_data (cmpny_id, description) FROM stdin;
\.


--
-- Data for Name: t_cmpny_eqpmnt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_eqpmnt (id, cmpny_id, eqpmnt_id, eqpmnt_type_id, eqpmnt_type_attrbt_id, eqpmnt_attrbt_val, eqpmnt_attrbt_unit) FROM stdin;
\.


--
-- Data for Name: t_cmpny_flow; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_flow (id, cmpny_id, flow_id, qntty, cost, ep, flow_type_id, potential_energy, potential_energy_unit, supply_cost, supply_cost_unit, transport_id, output_location, substitute_potential, comment, data_quality, entry_date, consultant_id, flow_category_id, function, description, chemical_formula, availability, concentration, pression, ph, state_id, quality, min_flow_rate, min_flow_rate_unit, max_flow_rate, max_flow_rate_unit, cost_unit_id, ep_unit_id, qntty_unit_id, concunit, presunit, character_type) FROM stdin;
5	7	2	1000.00	1000.00	12	2	0.00	0	0.00	0	\N	\N			\N	0001-01-01 00:00:00	0	\N				\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
13	9	1	1000.00	10.00	100	1	0.00	0	0.00	0	\N	\N			\N	0001-01-01 00:00:00	0	\N				\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	9	2	123.00	123.00	123	1	0.00	0	0.00	0	\N	\N			\N	0001-01-01 00:00:00	0	\N				\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
18	9	2	1276.00	210.00	1234	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-14 07:21:30.303	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
21	35	3	6873270.00	13680763.00	20619810	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-16 11:58:50.085	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	35	6	25618560.00	17605638.00	28180416	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-16 14:15:01.418	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
36	35	6	17932992.00	12323946.00	19726291	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-16 14:25:46.994	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
637	3419	224	62600000.00	58900.00	234937800	1	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-18 14:15:36.991834	\N	\N	\N	Supplied water	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
625	3419	215	10000000.00	5000000.00	35220000000	1	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-18 10:47:00.572761	\N	\N	\N	Conventionel and organic milk, 1.65 million kg for cheese milk production	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1052	3500	301	75000000.00	1500000.00	328931.25	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 17:13:44.108922	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
182	61	4	10.00	10.00	10	1	\N	\N	\N	\N	\N				\N	2014-12-16 15:02:47.76	\N	\N	\N			f	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
183	61	8	10.00	10.00	10	1	\N	\N	\N	\N	\N				\N	2014-12-16 15:45:18.309	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
865	3455	294	540.00	6885.00	0.5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:47:18.796165	\N	\N	\N	12.75 Chf pro kg 5%	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
185	61	14	10.00	10.00	10	1	\N	\N	\N	\N	\N				\N	2014-12-17 10:22:57.627	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
657	3422	225	100000.00	50000.00	359419000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2019-01-08 15:01:54.24146	\N	\N	\N	calf feeding	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
187	61	35	10.00	10.00	10	1	\N	\N	\N	\N	\N			aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa	\N	2014-12-17 10:30:46.46	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
792	3447	262	697.49	722.86	837.542761899999959	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-03 10:34:10.619288	\N	\N	\N	plastic waste from hotel to incineration plant	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
801	3448	266	1501875.00	0.00	62875600650	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-12 09:43:24.027619	\N	\N	\N	The nitrogen oxides (NOx) emissions from clinker production.	\N	t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
666	3423	66	20592.00	2340000.00	186169459.563057482	1	\N	\N	\N	\N	\N				\N	2019-01-22 09:55:26.404356	\N	\N	\N	Offset aluminium Al 99,9% printing plates: 1030 x 790 x 0.4 mm		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
673	3423	66	20595.00	-23400.00	186169460	2	\N	\N	\N	\N	\N			23'400 units (0,88 kg/unit	\N	2019-01-29 09:19:18.936586	\N	\N	\N	Used offset aluminium Al 99,9% printing plates: 1030 x 790 x 0.4 mm		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
933	3459	290	242086.00	6268.00	4.37000000000000011	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 18:45:07.625626	\N	\N	\N	Abw├ñrme Verluste	\N	t	\N	\N	\N	3	\N	\N	\N	\N	\N	CHF	EP	6	\N	\N	\N
685	3428	231	62600.00	106420.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:24:17.660021	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
688	3428	233	10000000.00	5000000.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:39:40.134538	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
709	3435	224	62600.00	106420.00	234.937799999999982	1	\N	\N	\N	\N	\N			costs incl. waste water	\N	2019-04-08 14:20:54.614845	\N	\N	\N	Water at tap		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
736	3435	243	1350.00	5400000.00	3523.5	1	\N	\N	\N	\N	\N				\N	2019-04-08 15:43:18.90022	\N	\N	\N	Halades PE 15, chemical for cold sterlilisation		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
738	3438	241	300000.00	30000.00	1056600	1	\N	\N	\N	\N	\N				\N	2019-05-17 21:07:30.785877	\N	\N	\N	rawmilk for calve feeding		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	22	\N	\N	\N
740	3443	238	62600.00	102000.00	8519.86000000000058	1	\N	\N	\N	\N	\N				\N	2019-05-20 08:59:21.415488	\N	\N	\N	District heat from waste incineration plant		t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
618	3417	99	1000.00	200000.00	23000000	2	\N	\N	\N	\N	\N				\N	2018-10-16 11:41:51.91526	\N	\N	\N	excess heat from processes		t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	\N
1005	3471	332	1802000.00	236000.00	919.019999999999982	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 07:47:38.842721	\N	\N	\N	Strom Gesamt	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
795	3448	264	70522000.00	7757463.00	1497427465	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-11 16:22:22.176357	\N	\N	\N	The EP from petroleum itself. Yearly 70'522 t petcoke is used for our clinker production. Petcoke price of 80CHF/t, additional costs for transport and grinding.	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
754	3444	1	10000.00	20.00	4600	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-02-12 10:49:19.088762	\N	\N	\N	Fresh water for the beverage	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
807	3368	10	10000.00	2000.00	5000	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-07-13 13:38:05.956913	\N	\N	\N	awdaw	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
822	3451	278	580000.00	320000.00	2030000000	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-08-18 09:57:07.280839	\N	\N	\N	Eigens erstellt (ohne "_") zu testzwecken.	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
832	3453	285	1213.00	61541.00	138828	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-19 12:23:33.660932	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	26	\N	\N	\N
1016	3474	323	80000.00	0.00	0	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-05 16:01:07.271036	\N	\N	\N	RDF burning to produce energy	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	4	\N	\N	\N
626	3419	216	1800000.00	2360000.00	917640000	1	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-18 10:52:03.833679	\N	\N	\N	Electricity	\N	t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
888	3457	291	906613.00	23500.00	15.5899999999999999	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:35:17.174922	\N	\N	\N	W├ñrmeerzeugung	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	6	\N	\N	\N
890	3457	294	540.00	6885.00	0.5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-12 08:32:14.130372	\N	\N	\N	5%	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
877	3460	293	38050.00	1000.00	131.810000000000002	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:12:01.417304	\N	\N	\N		\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1021	3474	80	150521.00	0.00	0.0200000000000000004	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-05 16:07:50.045064	\N	\N	\N	Dust emission during petcoke burning	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
667	3423	226	767000.00	92040.00	177416682.574341327	1	\N	\N	\N	\N	\N				\N	2019-01-22 10:00:10.11871	\N	\N	\N	swiss electricity mix		t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
668	3423	227	1000000.00	1000000.00	3528420536.86969995	1	\N	\N	\N	\N	\N				\N	2019-01-22 10:02:04.907122	\N	\N	\N	print paper		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
669	3424	66	6600.00	500000.00	59669698.5779030398	1	\N	\N	\N	\N	\N				\N	2019-01-22 10:16:54.641077	\N	\N	\N	Aluminum Al 99,9% plates: 1000 x 600 x 0.4 mm		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
661	3423	133	20592.00	-23400.00	186169460	2	\N	\N	\N	\N	\N			23'400 units (0,88 kg/unit)	\N	2019-01-16 17:18:34.168166	\N	\N	\N	Used offset aluminium Al 99,9% printing plates: 1030 x 790 x 0.4 mm		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
783	3447	205	582000.00	14761.00	39400	1	\N	\N	\N	\N	\N	\N	District heating	\N	\N	2020-04-22 12:49:31.397859	\N	\N	\N	Heating oil	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	6	\N	\N	\N
672	3423	228	30000.00	-1200.00	105852616	2	\N	\N	\N	\N	\N			Returns in paper manunfacturing	\N	2019-01-22 16:11:30.362271	\N	\N	\N	Ink free		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
710	3435	240	1800.00	236000.00	917.6400000000001	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:24:06.674659	\N	\N	\N	Industry electricity mix, mainly from coal and nuclear power plants		t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
737	3441	243	1350.00	5400000.00	2.60999999999999988	1	\N	\N	\N	\N	\N				\N	2019-04-08 15:45:29.817051	\N	\N	\N	Halades PE 15, chemical for cold sterlilisation		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
906	3462	276	1310.00	2531.00	0.550000000000000044	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-24 23:06:59.05716	\N	\N	\N	Wasser zum Brauprozess	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
741	3443	224	62600.00	106420.00	234.93780000000001	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:04:02.017934	\N	\N	\N	Water at tap, costs incl. waste water		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
746	3443	241	10000000.00	5000000.00	35220000	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:16:03.90459	\N	\N	\N	Rawmilk from cow farms		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
919	3466	272	92000.00	27600.00	21.4800000000000004	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-30 10:10:29.711358	\N	\N	\N	Stromverbrauch von diesem 40 Personen Haushalt. Annahme 2300 kwh pro Person und Jahr kwh = 30Rp.	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
739	3443	243	675.00	2700.00	7.12790999999999997	1	\N	\N	\N	\N	\N				\N	2019-05-18 15:24:02.750307	\N	\N	\N	Halades PE 15, chemical for cold sterlilisation		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
747	3443	225	580000.00	350000.00	0	2	\N	\N	\N	\N	\N				\N	2019-05-20 09:29:41.248846	\N	\N	\N	Rawmilk losses		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
755	3444	244	100000.00	4000.00	440000000	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-02-12 10:50:54.076974	\N	\N	\N	Hop for the beer	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
787	3447	258	2842.00	4704.00	1305	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-24 09:21:35.076803	\N	\N	\N	total tap water	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
343	9	10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2015-04-06 14:27:50.114	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
344	9	8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2015-04-06 14:27:50.114	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
791	3447	261	13.00	877.00	1703.3900000000001	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-01 09:29:10.212299	\N	\N	\N	Production of R407C	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
793	3447	263	13.00	0.00	10588.5	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-06 12:07:43.165854	\N	\N	\N	release refrigerant R407C into air	\N	t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
780	3446	225	579063.00	318500.00	2039459886	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-18 12:11:53.883879	\N	\N	\N		\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
760	3446	224	62559000.00	59500.00	23478393	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-14 11:59:56.315202	\N	\N	\N	water price: CHF 1.90/m^3\r\ntotal water amount per year for milk processing and sterilisation	\N	t	\N	\N	\N	2	Tap Water	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
934	3459	294	540.00	5000.00	0.5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 18:52:57.250082	\N	\N	\N	Reinigungsmittel	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
796	3448	153	26526316.00	132631.00	26144964800	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-12 07:29:58.968586	\N	\N	\N	Residue Derived Fuel (RDF) is used to substitute petcoke fuel. 26526316 kg RDF/a is used.  At the end of pre- and co-processing the costs are 5 CHF/t plastic waste (RDF).	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
808	3368	268	10000.00	2000.00	1234	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-07-13 14:21:58.439199	\N	\N	\N	awd	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	EP	1	\N	\N	\N
1053	3486	351	4024.00	8000000.00	0.0200000000000000004	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 17:19:36.422908	\N	\N	\N		\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
833	3452	287	20000000.00	6000000.00	111852800000	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-21 14:20:04.941508	\N	\N	\N	cows have to eat too	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
834	3451	276	10000.00	3000.00	4600	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-28 07:14:18.39057	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
839	3460	272	50726.59	12994.00	11.8399999999999999	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:01:02.523217	\N	\N	\N		\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
870	3461	290	905893.00	36236.00	16.3500000000000014	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:59:13.477846	\N	\N	\N	1.6 CHF/kg Erdgas\r\n1kg = ca. 40 MJ	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
949	3463	306	30.00	200000.00	0.0299999999999999989	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-21 06:54:53.358133	\N	\N	\N	Nuclear fuel Type xy	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
991	3476	57	2000000.00	20000.00	828	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-26 11:19:27.802865	\N	\N	\N	Cutoffs of wood	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1006	3471	277	9407000.00	5170000.00	44306.9700000000012	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 07:49:49.663875	\N	\N	\N	Gesamt Raw Milk	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
240	94	69	1270.00	12700.00	127000	2	\N	\N	\N	\N	\N				\N	2015-02-24 16:42:21.398	\N	\N	\N	Hot		t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
1007	3471	333	62559000.00	1119000.00	259718	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-28 07:51:19.889662	\N	\N	\N	Total water input (impact of WW treatment already considered)	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1017	3474	2	800.00	160000.00	0	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-05 16:02:31.268814	\N	\N	\N	Electricity input	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	9	\N	\N	\N
636	3419	223	2731000.00	102000.00	371689100	1	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-18 11:42:51.717975	\N	\N	\N	District heat (steam) from a waste incineration plant	\N	t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
656	3422	215	100000.00	50000.00	352200000	1	\N	\N	\N	\N	\N				\N	2019-01-08 07:35:46.128994	\N	\N	\N	Calf feeding		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP/kg	3	\N	\N	\N
1030	3472	323	80000.00	1000.00	0	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-19 07:19:22.505317	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	4	\N	\N	\N
670	3424	66	2247.00	-2247.00	20314820.1067497171	2	\N	\N	\N	\N	\N				\N	2019-01-22 10:19:40.654247	\N	\N	\N	aluminium waste		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
711	3441	224	62600.00	106420.00	0.00375299999999999983	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:24:18.713231	\N	\N	\N	water at tap		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
732	3435	241	10000000.00	5000000.00	35220000	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:54:25.420947	\N	\N	\N	Rawmilk from cow farms		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
788	3447	259	2842.00	4605.00	10490	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-24 09:22:49.303363	\N	\N	\N	total waste water	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
742	3443	240	1800.00	236000.00	917.6400000000001	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:05:45.94757	\N	\N	\N	Industry electricity mix, mainly from coal and nuclear power plants		t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
748	3443	222	1000.00	3500.00	1583	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:31:14.094026	\N	\N	\N	Sodium hydroxide for CIP cleaning		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
784	3447	230	494000.00	13711.00	2050	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-22 12:54:36.139835	\N	\N	\N		\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	6	\N	\N	\N
750	3443	69	62600000.00	9390.00	27.9195999999999991	2	\N	\N	\N	\N	\N				\N	2019-05-20 09:35:45.739323	\N	\N	\N	Waste water with high organic load		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
756	3444	245	1000.00	2000.00	15000	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-02-12 10:52:36.93559	\N	\N	\N	brewers yeast	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1037	3491	345	160.00	2160.00	0.770000000000000018	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 11:36:36.455161	\N	\N	\N	Palm├Âl wird mir dem Zucker zusammen erw├ñrmt	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1038	3491	346	280.00	224.00	0.28999999999999998	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 11:50:35.400877	\N	\N	\N	Zucker wird dem Palm├Âl zugegeben und gemeinsam zu homogenem Gemisch verarbeitet	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
771	3446	69	62559000.00	59500.00	27901314	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-15 15:12:03.58578	\N	\N	\N	All water goes to waste\r\nThe cost of the water and wastewater are split 50/50	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
761	3446	187	940.50	3291.75	5591273	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-14 12:28:47.372923	\N	\N	\N	price phosphoric acid: CHF 3.5/kg\r\nCIP cleaning	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
797	3448	265	594599.00	22341504.00	273515540000	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-12 07:55:49.869053	\N	\N	\N	The EP for CO2 emissions from producing 675000 t clinker annual. Cost for CO2 fee/tax of 96.- CHF / t CO2.	\N	t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
802	3448	267	4860000.00	486000.00	10011600000	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-12 12:02:17.705624	\N	\N	\N	Ammonia used for SNCR NOx reduction technology. Ammonia cost 100 CHF/t.	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
809	3447	269	10000.00	2000.00	186000000	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-07-17 14:06:30.164364	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	30	\N	\N	\N
837	3451	288	1222.00	213123.00	0.0200000000000000004	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-24 17:26:17.820265	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	26	\N	\N	\N
845	3455	291	905893.20	23454.13	15.5800000000000001	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:11:41.837133	\N	\N	\N		\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
840	3455	272	50726.59	12994.00	11.8399999999999999	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:01:02.738114	\N	\N	\N		\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
871	3460	290	242085.60	6267.70	4.37000000000000011	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:59:28.356195	\N	\N	\N	Abw├ñrme verluste	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
878	3458	283	994.64	825.55	1.72999999999999998	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:13:17.438584	\N	\N	\N		\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
891	3457	275	540.00	5262.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-12 08:35:16.639332	\N	\N	\N	3%	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
907	3460	301	10000.00	1000.00	43.8599999999999994	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-25 07:46:46.165563	\N	\N	\N	test	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
922	3468	272	50727.00	12994.00	10.7799999999999994	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 08:51:36.767169	\N	\N	\N	Energiebedarf f├╝r die Brauerei	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
937	3459	276	1310000.00	2513.00	0.599999999999999978	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 20:23:24.200301	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
992	3477	320	500000.00	1000.00	0.46000000000000002	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-26 11:36:31.147531	\N	\N	\N	General use, metal part cleaning	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1018	3474	324	120000.00	800000.00	0.0299999999999999989	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-05 16:03:18.708562	\N	\N	\N	Petcoke transport	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	4	\N	\N	\N
951	3458	306	100.00	58900.00	0.100000000000000006	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-22 04:36:49.451616	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1031	3474	343	1280000.00	38758400.00	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-05-19 08:16:50.581424	\N	\N	\N	Biogas	\N	t	\N	\N	\N	3	\N	\N	\N	\N	\N	CHF	EP	7	\N	\N	\N
765	3446	249	2371000.00	102000.00	322693100	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-14 13:16:10.06858	\N	\N	\N	cost district heat: CHF 0.043/kWh\r\ntotal heat for CIP cleaning, pasteurising milk & hot sterilisation (steam)	\N	t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
781	3446	206	940.50	3291.75	1488812	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-18 12:23:02.054245	\N	\N	\N	Price of sodium hydroxide is 3.50 CHF/kg	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
671	3424	226	300000.00	36000.00	69393748.073405996	1	\N	\N	\N	\N	\N				\N	2019-01-22 10:20:39.699799	\N	\N	\N	swiss electricity mix		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
1033	3490	301	200.00	1000.00	0.880000000000000004	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-11-17 17:08:29.273142	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
799	3448	80	7101.00	0.00	845019000	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-12 08:43:40.767712	\N	\N	\N	Dust emissions from the clinker production.	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
689	3428	234	1000.00	3500.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:44:26.989397	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
704	3439	222	1000.00	3500.00	1.58299999999999996	1	\N	\N	\N	\N	\N				\N	2019-04-01 16:28:03.626692	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
706	3439	241	580000.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2019-04-01 16:30:21.15577	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
712	3441	240	1800.00	236000.00	0.509800000000000031	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:27:25.067146	\N	\N	\N	ind.electicity mix, manly from coal and and nuclear power plants		t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
716	3441	222	1000.00	3500.00	1.58299999999999996	1	\N	\N	\N	\N	\N			for CIP cleaning	\N	2019-04-08 14:34:18.536269	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1039	3491	347	80.00	16.00	0.119999999999999996	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 11:56:54.397762	\N	\N	\N	Karotten werden zerkleinert, getrocknet und dem Hafergemenge zugegeben	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
814	3451	274	1000.00	3500.00	5384600	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-18 09:35:50.06597	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
752	3442	225	100000.00	50000.00	359419000	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:47:48.639901	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
757	3444	99	5000.00	2000.00	90250	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-02-12 10:55:07.79982	\N	\N	\N		\N	t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	6	\N	\N	\N
978	3478	318	2000000.00	146000.00	250	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:14:43.423084	\N	\N	\N	Heat Energy produced with natural gas	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	Euro	\N	8	\N	\N	\N
844	3460	290	905893.20	23454.13	16.3500000000000014	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:11:38.928174	\N	\N	\N	Heizenergie	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
981	3479	319	200000.00	50000.00	82.7999999999999972	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:21:24.279716	\N	\N	\N	Hardwood chips, cutoffs and sawdust	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
854	3457	293	37680.00	7000.00	130.530000000000001	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:28:06.296237	\N	\N	\N	Malz und Hopfen f├╝r Brauprozess	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
993	3478	321	10000000.00	1000000.00	1240	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-26 12:40:01.408934	\N	\N	\N		\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
866	3460	275	540.00	5000.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:47:44.835983	\N	\N	\N	Reinigungsmittel	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
861	3458	294	540.00	6885.00	0.5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:43:34.011198	\N	\N	\N		\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
859	3456	275	540.00	5262.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:38:56.457281	\N	\N	\N	Aus Fallstudie Ueli. Annahme da nicht ver├ñndert wird	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
762	3446	215	9407000.00	5170000.00	33131454000	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-14 12:35:59.154482	\N	\N	\N	price raw milk: CHF 0.55/kg	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
884	3460	283	1076.60	2099.00	4	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:26:14.231657	\N	\N	\N	Abwasser	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
892	3463	293	100000.00	1000000.00	346.399999999999977	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-12 09:37:56.366801	\N	\N	\N	Futter f├╝r die Schweine	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
897	3463	298	1000000.00	10000.00	3476.59999999999991	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-19 08:11:24.216747	\N	\N	\N	Feed	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
896	3455	298	38050.00	1900.00	66.0600000000000023	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-19 08:09:04.841565	\N	\N	\N	Treber	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
908	3458	298	38050.00	1900.00	66	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-25 08:57:46.415913	\N	\N	\N	Treber f├╝r Viehfutter	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
923	3468	291	906613.20	23500.00	15.5899999999999999	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 08:53:26.319757	\N	\N	\N	W├ñrme die f├╝r den Brauprozess ben├Âtigt werden	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
1008	3472	334	937.00	2224.00	1.65999999999999992	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-28 08:34:31.696128	\N	\N	\N		\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
841	3456	272	55265.00	14181.00	11.8399999999999999	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:04:14.79664	\N	\N	\N	Elektrischer Strom f├╝r Betrieb, Beleuchtung und K├╝hlung des Brauprozesses	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
938	3459	283	1077.00	2099.00	4.12999999999999989	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 20:24:12.80748	\N	\N	\N	Abwasser	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
1019	3474	341	2508683.00	0.00	0.100000000000000006	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-05 16:04:05.311866	\N	\N	\N	NOx emitted during the petcoke burning	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1034	3489	301	27985.00	259769.00	10.2400000000000002	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-11-17 17:11:46.226985	\N	\N	\N	Pislner Malz: 2335.-\r\n+\r\nNatur Hopfen: 25650.-	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
698	3435	238	2731.00	102000.00	371.689099999999996	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:55:38.765127	\N	\N	\N	District heat from waste incineration plant		t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
713	3428	215	10000000.00	5000000.00	35220000000	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:30:09.058792	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
717	3441	69	62600.00	0.00	27.9195999999999991	2	\N	\N	\N	\N	\N			no costs because is included	\N	2019-04-08 14:37:24.000937	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
702	3439	241	10000000.00	5000000.00	3.5219999999999998	1	\N	\N	\N	\N	\N				\N	2019-04-01 16:26:26.334443	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
744	3443	221	1000.00	3500.00	5945	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:12:39.352029	\N	\N	\N	Phosphoric acid for CIP cleaning		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
751	3442	241	100000.00	50000.00	352200	1	\N	\N	\N	\N	\N				\N	2019-05-20 09:45:49.778225	\N	\N	\N	For feeding calves		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
758	3444	69	3000.00	2000.00	5000	2	\N	\N	\N	\N	\N	\N		\N	\N	2020-02-12 16:21:30.591598	\N	\N	\N		\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
826	3451	281	1800000.00	2360000.00	979704000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-08-18 16:00:09.544199	\N	\N	\N	Keine Ahnung in welcher Form die Energie sein sollte, stimmt aber etwa in der Gr├Âssenordnung.	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
825	3451	280	2731000.00	102000.00	370000000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-08-18 15:57:45.20134	\N	\N	\N	Werte waren zuerst bezogen auf MJ. EP wurden im Editor angepasst.	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
1040	3500	348	100000.00	300000.00	1000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 16:18:23.759282	\N	\N	\N	Frischwasser ab Leitung	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
846	3456	290	905893.00	23454.00	16.3500000000000014	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:12:17.363966	\N	\N	\N	Erdgas mix CH. Preis aus Fallstudie Ueli	\N	t	\N	\N	\N	3	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
842	3458	272	53007.00	12994.00	12.3699999999999992	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:07:06.16757	\N	\N	\N		\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
880	3461	294	540.00	810.00	0.5	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-05 08:20:29.197324	\N	\N	\N	1 kg ca 1.5 CHF	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
893	3444	297	78678.00	456.00	60.8999999999999986	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-12 16:29:01.408044	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
898	3457	298	19200.00	1900.00	66.75	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-19 09:05:11.082015	\N	\N	\N	Treberkuchen Entsorgung; Abwasserfracht	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
920	3468	293	37680.00	7000.00	130.530000000000001	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 08:47:54.94946	\N	\N	\N	Malz und Hopfen f├╝r Brauprozess	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
924	3468	276	1310000.00	2531.00	0.599999999999999978	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 08:55:40.794623	\N	\N	\N	Wasser f├╝r den Brauprozess	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
952	3422	224	1000000.00	3000.00	3.75	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-22 08:42:54.046965	\N	\N	\N	xxxx	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	22	\N	\N	\N
1009	3471	335	5362.00	3753.00	28.3000000000000007	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 08:42:32.322848	\N	\N	\N	0,7 CHF / kg	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
635	3419	222	1000.00	3500.00	1583000	1	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-18 11:39:47.784191	\N	\N	\N	Alkaline cleaning chemical	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
803	3448	2	6338250.00	633825.00	1476812250	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-12 12:17:52.507649	\N	\N	\N	Additional electricity needed for the dust filter technology. Electricity cost of 0.1CHF/kWh	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
692	3428	236	62600.00	0.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:46:08.489401	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
696	3425	215	300000.00	30000.00	0	2	\N	\N	\N	\N	\N				\N	2019-04-01 15:52:41.718673	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	22	\N	\N	\N
715	3441	221	1000.00	3500.00	5.94500000000000028	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:33:08.349996	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
816	3451	275	1000.00	3500.00	1280600	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-18 09:38:57.227794	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
718	3431	223	2731.00	102000.00	136100	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:40:19.296601	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
843	3458	290	905893.20	23454.13	16.3500000000000014	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:11:34.351603	\N	\N	\N		\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
850	3460	276	1310000.00	2512.60	0.599999999999999978	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:16:43.898086	\N	\N	\N		\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1020	3474	338	1332738.00	64169.92	0	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-05-05 16:05:17.241905	\N	\N	\N	NH3 input for the NOx reduction	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
858	3456	294	540.00	6885.00	0.5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:38:07.339534	\N	\N	\N	Aus Fallstudie Ueli. Annahme da nicht ver├ñndert wird	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
875	135	283	10000.00	2000.00	38.3299999999999983	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 09:53:23.247221	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	20	\N	\N	\N
883	3461	275	540.00	9180.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-05 08:24:48.856476	\N	\N	\N	17 CHF/kg	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
882	3457	293	19200.00	0.00	66.5100000000000051	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:22:17.929557	\N	\N	\N	Treber/Malzkuchen Trockensubstanz	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1035	3486	344	3684.00	5000000.00	132046.049999999988	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-11-17 17:17:04.969715	\N	\N	\N	Baumwolle	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
925	3468	276	451000.00	338.00	0.209999999999999992	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 08:56:59.100708	\N	\N	\N	Abwasser das beim Brauprozess entsteht	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
941	3456	298	19000.00	1.00	66.0600000000000023	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 21:50:03.999972	\N	\N	\N	Schweinefutter	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1041	3486	276	637615.00	682248.00	0	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 16:33:28.915415	\N	\N	\N	Wasser	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
977	3481	314	35000000.00	75000000.00	379505	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:12:17.938433	\N	\N	\N	Aluminium, cast	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
980	3479	319	1200000.00	300000.00	496.800000000000011	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:20:07.209289	\N	\N	\N	Hardwood Planks	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
984	3480	314	20000.00	42000.00	216.860000000000014	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:27:54.526596	\N	\N	\N	Aluminium Sheets	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
1010	3471	275	5362.00	1877.00	8.67999999999999972	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 08:47:53.888389	\N	\N	\N	0,35 chf/kg	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
584	3405	85	7723.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 09:50:42.109106	\N	\N	\N	Crap paper (input)		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
594	3409	98	2480633.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:15:50.462373	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	
605	3412	24	12017.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:04:30.645007	\N	\N	\N	Apalit		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
613	3413	2	5836400.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:11:48.034027	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
684	3428	230	2731.00	102000.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:23:30.961137	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
694	3428	225	580000.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2019-04-01 15:48:43.41131	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
719	3441	225	580000.00	0.00	3.5219999999999998	2	\N	\N	\N	\N	\N			incl. wastewater costs	\N	2019-04-08 14:40:40.102325	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
721	3431	231	62600.00	106420.00	3753	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:41:47.772863	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
804	3448	262	26526316.00	132631.00	26144964800	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-13 07:24:18.179993	\N	\N	\N		\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
823	3452	277	100000.00	50000.00	350000000	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-18 09:58:41.233622	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1036	3489	276	2243000.00	224300.00	1.03000000000000003	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-11-17 17:20:47.837948	\N	\N	\N	Brauwasser	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
817	3451	276	62600000.00	58900.00	287960000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-08-18 09:40:21.105015	\N	\N	\N	oder eigenes "Wasser" erstellen? EP wurden im Editor angepasst (+0).	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
885	3455	283	1043.00	2033.85	3.68000000000000016	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:27:00.347373	\N	\N	\N		\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
1042	3495	344	36840000.00	22826.00	132.050000000000011	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 16:36:26.541804	\N	\N	\N		\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1044	3495	349	243000.00	124000.00	536.75	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 16:40:38.766078	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
847	3457	276	1310.00	2531.00	0.110000000000000001	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:12:53.889826	\N	\N	\N	Wasserbedarf Brauererei	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
901	3465	299	38050.00	3800.00	0	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-19 09:33:20.377026	\N	\N	\N	Schweinefutter von Brauerei 10 rp./kg	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1046	3495	272	9000000.00	1000000.00	2100.86999999999989	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 16:46:12.505884	\N	\N	\N		\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
917	3467	303	200000.00	10000.00	0.209999999999999992	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-28 10:37:19.030082	\N	\N	\N	Wasser f├╝r Bioreaktoren	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1051	3500	353	46.00	80000.00	86.8499999999999943	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 17:01:13.732052	\N	\N	\N	Entsorgung des trebers ├╝ber Abwasser	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	4	\N	\N	\N
942	3469	272	100000.00	0.30	23.3399999999999999	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 22:16:44.943412	\N	\N	\N	generierte elektrische Energie durch PV- Anlage auf dem Dach	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
915	3462	276	451000.00	338.00	0	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-28 09:51:03.269882	\N	\N	\N		\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
979	3479	316	55300.00	20000.00	629.149999999999977	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:18:43.450128	\N	\N	\N	Steel chromium	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
986	3477	316	1454545.00	800000.00	16548.3600000000006	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:30:33.314111	\N	\N	\N	Steel Chromium	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
805	3449	225	840.00	84.00	2958.48000000000002	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-05-14 15:21:38.632754	\N	\N	\N	Waste milk for calf feeding. 2 weeks, 6kg per calf, 10 calfs at the farm	\N	t	\N	\N	\N	2	Animal feed grade	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
585	3405	2	1514000.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 09:51:41.813517	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
586	3405	1	3903.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 09:52:28.499928	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
591	3409	60	600002.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 10:13:28.77457	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
593	3409	170	45090.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:15:09.632464	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
597	3410	1	1555931.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:49:01.047951	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
599	3411	24	79726.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 10:55:06.755357	\N	\N	\N	N2 (product)		t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	
604	3412	68	2217.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 11:03:29.940767	\N	\N	\N	Zeolit (product)		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
607	3412	123	10747.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:05:45.040874	\N	\N	\N	Ure		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
609	3412	127	17522.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:07:06.025407	\N	\N	\N	Kali		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
824	3452	278	100000.00	50000.00	350000000	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-18 09:59:02.559482	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
687	3428	2	1800.00	236000.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:38:42.223213	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
701	3439	240	1800.00	236000.00	0.509800000000000031	1	\N	\N	\N	\N	\N				\N	2019-04-01 16:03:24.012183	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
722	3435	221	1000.00	3500.00	5945	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:43:03.127748	\N	\N	\N	Phosphoric acid for CIP cleaning	H3PO4	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
821	3451	277	10000000.00	5000000.00	35000000000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-08-18 09:56:33.390433	\N	\N	\N	Eigens erstellt (ohne "_") zu testzwecken.	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
725	3431	233	10000000.00	5000000.00	3522	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:45:00.689392	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
723	3431	242	1800.00	236000.00	509800	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:43:56.343747	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
735	3431	229	1350.00	5400000.00	2610000	1	\N	\N	\N	\N	\N				\N	2019-04-08 15:42:31.370709	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
848	3461	292	50726.00	13472.00	1.57000000000000006	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:16:17.135422	\N	\N	\N	Kosten: 50726 kWh x 26.56 Rp. (Strompreis Basel)	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
857	3460	293	38050.00	38000.00	131.810000000000002	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:33:55.065268	\N	\N	\N	Hopfen, Malz und Hefe in einem	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
867	3455	275	540.00	5262.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:49:33.770136	\N	\N	\N	975 pro kg 3%	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
886	3456	283	1075.00	0.00	4.12000000000000011	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-05 08:30:35.191598	\N	\N	\N	Bereits mit Tap Water-Geb├╝hr bezahlt. Von Flussdiagramm Ueli	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	20	\N	\N	\N
905	3465	298	1000000.00	1000.00	3476.59999999999991	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-19 10:10:19.64679	\N	\N	\N	Schweinefutter	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
912	3462	293	37680.00	7000.00	130.530000000000001	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-28 09:30:00.620609	\N	\N	\N	"Malz" zum brauen	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
943	3462	290	906613.00	23500.00	16.3599999999999994	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 23:49:29.980556	\N	\N	\N	W├ñrmeenergie	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
1043	3486	349	243.00	124003.00	536.75	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 16:38:37.747579	\N	\N	\N	H2O2	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
985	3480	316	10000.00	5500.00	113.769999999999996	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-23 14:28:52.856021	\N	\N	\N	Steel Chromium Sheets	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
989	3481	320	10000000.00	10000.00	9.19999999999999929	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-24 05:30:22.298954	\N	\N	\N	Process water consumption	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
1047	3495	350	5530.00	31000.00	50.1700000000000017	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 16:50:02.95488	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
587	3405	84	2680.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 09:53:10.002802	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
588	3408	2	1175800.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:09:13.915236	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
592	3409	2	6967591.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:14:40.88094	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
614	3413	1	261126.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:12:19.301495	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
690	3428	235	1000.00	3500.00	0	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:45:19.00918	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
703	3439	221	1000.00	3500.00	5.94500000000000028	1	\N	\N	\N	\N	\N				\N	2019-04-01 16:27:25.591741	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
705	3439	69	62600.00	0.00	0.000445999999999999999	2	\N	\N	\N	\N	\N				\N	2019-04-01 16:29:06.906208	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
727	3435	69	62600.00	0.00	27.9195999999999991	2	\N	\N	\N	\N	\N				\N	2019-04-08 14:46:57.384265	\N	\N	\N	costs included in 'water at tap'		t	\N	\N	\N	2	high organic load	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
726	3431	221	1000.00	3500.00	5945	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:46:33.104697	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
1045	3486	272	8943726.00	1073247.00	2087.73000000000002	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 16:43:20.535437	\N	\N	\N	Strom	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
634	3419	221	1000.00	3500.00	5945000	1	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-18 11:38:42.52275	\N	\N	\N	Acidic cleaning chemical	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
772	3446	2	1802000.00	236000.00	918659600	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-15 15:15:04.181475	\N	\N	\N	cost electricity: CHF 0.131/kWh\r\ntotal electricity for CIP cleaning, pasteurising milk & hot sterilisation	\N	t	\N	\N	\N	4		\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
820	3451	279	62600000.00	58900.00	27560000	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-08-18 09:55:48.713949	\N	\N	\N	Eigens erstellt zu testzwecken. EP angepasst im Editor.	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
849	3458	276	1310000.00	6508.22	0.599999999999999978	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:16:40.945329	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
868	3460	294	540.00	5000.00	0.5	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:51:11.510553	\N	\N	\N	Reinigungsmittel	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
889	3457	276	451.00	338.00	0.209999999999999992	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-05 08:46:59.180756	\N	\N	\N	Abwassser	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
918	3455	304	64499.00	4440.00	11.5800000000000001	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-30 09:59:06.810488	\N	\N	\N	Photovoltaik Anlage auf Dach	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
928	3460	298	19000.00	1000.00	66.0600000000000023	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 10:43:17.764126	\N	\N	\N	Treber	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
944	3464	305	40000.00	10000.00	139.199999999999989	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 23:52:16.42303	\N	\N	\N	Rohstoff f├╝r Riegel	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
913	3462	293	19200.00	1000.00	66.5100000000000051	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-28 09:48:52.035941	\N	\N	\N	Malzkuchen nach dem Brauen	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
999	3472	327	152088.00	11056.00	32.8500000000000014	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 07:31:50.294226	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
589	3408	1	18288.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:09:49.903736	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
606	3412	129	15802.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:05:05.24634	\N	\N	\N	DAP		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
827	3451	282	333.00	3333.00	110889	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-19 09:50:51.278837	\N	\N	\N	Just messing around	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
700	3439	224	62600.00	106420.00	0.00375299999999999983	1	\N	\N	\N	\N	\N				\N	2019-04-01 16:01:50.418368	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
1029	3474	264	180000.00	72985700.00	243000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-05-07 13:12:25.862449	\N	\N	\N	Petecoke input incl emissions from burning	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
708	3441	238	2731.00	102000.00	0.136099999999999999	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:18:41.908433	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
730	3435	241	580000.00	290000.00	2042760	2	\N	\N	\N	\N	\N				\N	2019-04-08 14:53:06.76729	\N	\N	\N	Rawmilk losses		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
728	3431	222	1000.00	3500.00	1583	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:47:10.679369	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
852	3461	276	238220.00	345.40	0.110000000000000001	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:23:07.579976	\N	\N	\N	Kosten: (238220 l x 1.45 CHF)/1000 \r\nEinheitspreis IWB Trinkwasser = 1.45 CHF/m3	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
773	3446	251	40.50	162.00	106705	1	\N	\N	\N	\N	\N	\N		\N	\N	2020-04-16 11:55:41.282625	\N	\N	\N	Chemical for cold sterilisation	\N	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
851	3456	276	1310000.00	6508.00	0.599999999999999978	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:17:42.824513	\N	\N	\N	Aus Fallstudie Ueli	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
862	3461	293	38080.00	38080.00	131.909999999999997	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:44:26.225308	\N	\N	\N	Kosten: angenommen 1 CHF pro kg	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
860	3455	293	38050.00	38050.00	131.810000000000002	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:42:54.694629	\N	\N	\N	1 CHF pro kg Hopfen, Malz und Hefe in einem	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
921	3468	293	19200.00	1000.00	66.5100000000000051	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 08:50:03.151562	\N	\N	\N	Treberkuchen vom Brauprozess (Entsorgungskosten wurden mit ~0.05 CHF pro Kg gerechnet)	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
929	3459	293	38050.00	38000.00	131.810000000000002	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 18:37:29.568115	\N	\N	\N	Hopfen, Malz, Hefe	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
945	3468	290	906613.00	23500.00	16.3599999999999994	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-02 00:48:29.906162	\N	\N	\N	F├╝r Brauprozesse und Heizung	\N	t	\N	\N	\N	3	true	\N	\N	\N	\N	CHF	\N	6	\N	\N	\N
914	3462	272	50727.00	12994.00	10.7799999999999994	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-11-28 09:50:00.69376	\N	\N	\N	Stromverbrauch	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
1000	3472	326	167779.00	12850.00	0.25	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-28 07:32:42.667426	\N	\N	\N		\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
828	3453	282	333333.00	333333.00	110999889	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-19 12:18:21.774385	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
853	3455	276	1310000.00	2512.60	0.599999999999999978	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:23:31.556979	\N	\N	\N	Daten aus Pr├ñsentation. Kosten 1.46 pro m3 + 600 CHF Grundpreis	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
699	3439	238	2731.00	102000.00	0.136099999999999999	1	\N	\N	\N	\N	\N				\N	2019-04-01 15:58:25.915481	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	9	\N	\N	\N
590	3409	60	62942.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:12:58.079259	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
595	3409	1	1200.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:16:18.26476	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
596	3410	2	6453.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:48:26.142996	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
600	3411	129	2312526.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 10:57:37.302709	\N	\N	\N	O2 (product)		t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	
601	3411	2	3305800.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 10:58:14.798691	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
602	3412	204	82360.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 11:02:19.221896	\N	\N	\N	fertilizer (product)		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
603	3412	189	6610.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 11:02:49.465813	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
608	3412	126	14191.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:06:32.431988	\N	\N	\N	SA		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
610	3412	2	4292712.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:07:35.521051	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
612	3413	24	71601.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 11:11:22.57536	\N	\N	\N	Milk (product)		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
916	3467	293	19200.00	15000.00	66.5100000000000051	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-11-28 10:34:54.792654	\N	\N	\N	N├ñhrstoffzusatz f├╝r Bioreaktor	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
714	3441	241	10000000.00	5000000.00	3.5219999999999998	1	\N	\N	\N	\N	\N			raw milk from cow farms	\N	2019-04-08 14:31:06.91987	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
724	3435	222	1000.00	3500.00	1583	1	\N	\N	\N	\N	\N				\N	2019-04-08 14:44:37.039041	\N	\N	\N	Sodium hydroxide for CIP cleaning	NaOH	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
930	3459	293	38050.00	1000.00	131.810000000000002	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 18:38:25.850169	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
935	3459	305	19000.00	1000.00	66.1200000000000045	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 20:21:24.211779	\N	\N	\N	Treber	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
946	3468	305	19000.00	1000.00	66.1200000000000045	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-02 14:31:31.926599	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
1049	3495	352	2575.00	24000000.00	0.0100000000000000002	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-12-01 16:58:16.900771	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	4	\N	\N	\N
1002	3472	329	2842.00	9307.00	11.0099999999999998	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 07:38:35.40766	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	20	\N	\N	\N
1004	3472	331	167779.00	12850.00	37	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-28 07:43:47.640862	\N	\N	\N		\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
652	3419	225	580000.00	320000.00	2084630200	2	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-19 13:19:16.794716	\N	\N	\N	Losses in milk/water phase at process start /end and from production failures. Total about 6% of rawmilk input	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
611	3412	1	43243.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-16 11:08:01.820106	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
733	3431	225	580000.00	290000.00	3522	2	\N	\N	\N	\N	\N				\N	2019-04-08 15:02:53.730207	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
829	3453	279	1000.00	50000.00	600	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-19 12:21:33.027207	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
653	3419	69	62600000.00	58900.00	27919600	2	\N	\N	\N	\N	\N	\N		\N	\N	2018-12-19 16:19:40.157868	\N	\N	\N	Waste water with high COD load	\N	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
408	93	79	12.00	12.00	12	1	\N	\N	\N	\N	\N				\N	2015-08-04 09:23:36.981	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
218	63	14	0.00	0.00	0	1	\N	\N	\N	\N	\N				\N	2015-01-29 16:22:59.82	\N	\N	\N			f	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
176	61	10	150000.00	1500000.00	150000	1	\N	\N	\N	\N	\N				\N	2014-12-16 14:24:25.767	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
177	61	3	150.00	1500000.00	150	2	\N	\N	\N	\N	\N				\N	2014-12-16 14:25:37.607	\N	\N	\N		Al	t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
178	61	2	100.00	1000.00	100	2	\N	\N	\N	\N	\N		none		\N	2014-12-16 14:39:40.158	\N	\N	\N			f	0	0	0	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
179	61	5	100.00	10.00	10	1	\N	\N	\N	\N	\N				\N	2014-12-16 14:58:25.259	\N	\N	\N		Cu	f	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
181	61	3	10.00	10.00	10	1	\N	\N	\N	\N	\N				\N	2014-12-16 15:01:26.39	\N	\N	\N			f	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
184	61	57	500.00	200.00	200	2	\N	\N	\N	\N	\N	2nd floor	none	don't touch	\N	2014-12-16 15:56:54.143	\N	\N	\N	hazardous substance	wood	t	50	10	2	1	good	\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
46	9	3	150.00	1000.00	3000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-24 08:53:09.521	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	TL	EP	1	\N	\N	\N
47	9	6	150.00	127.00	1000	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-24 08:55:48.238	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
49	35	5	2561856.00	1760563.00	28180416	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-29 15:15:09.156	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
50	35	5	768557.00	528169.00	8454125	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-29 15:17:09.813	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
51	35	2	100000.00	1000000.00	300000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-10-29 15:18:37.063	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
186	61	59	10.00	10.00	10	1	\N	\N	\N	\N	\N			aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa	\N	2014-12-17 10:29:05.598	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
188	62	60	14000.00	30800.00	14000	1	\N	\N	\N	\N	\N				\N	2015-01-07 09:23:43.524	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
189	62	61	500.00	27000.00	500	1	\N	\N	\N	\N	\N				\N	2015-01-07 09:24:36.056	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
224	24	68	1000.00	900.00	100	1	\N	\N	\N	\N	\N				\N	2015-02-11 14:46:10.292	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
190	62	62	10500.00	126000.00	10500	1	\N	\N	\N	\N	\N				\N	2015-01-07 09:25:38.754	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
191	63	62	10500.00	126000.00	10500	1	\N	\N	\N	\N	\N				\N	2015-01-07 15:08:24.892	\N	\N	\N		al	t	100	0	0	1	good	\N	\N	\N	\N	TL	EP	1	\N	\N	\N
227	88	5	250.00	300.00	250	1	\N	\N	\N	\N	\N				\N	2015-02-17 12:59:29.092	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
204	7	1	30000.00	5000.00	3000000	1	\N	\N	\N	\N	\N				\N	2015-01-27 09:04:44.899	\N	\N	\N		h20	t	0	0	0	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
192	63	60	14000.00	30800.00	14000	1	\N	\N	\N	\N	\N				\N	2015-01-07 15:11:10.856	\N	\N	\N		fe	t	100	0	0	1	good	\N	\N	\N	\N	TL	EP	1	\N	\N	\N
63	11	12	12000.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 11:18:03.463	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
193	63	61	500.00	27000.00	500	1	\N	\N	\N	\N	\N				\N	2015-01-07 15:12:24.699	\N	\N	\N			t	100	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
194	63	65	1000.00	3500.00	1000	1	\N	\N	\N	\N	\N				\N	2015-01-07 15:13:20.305	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
64	12	12	27000.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 11:19:07.632	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
65	13	12	55000.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 12:34:13.947	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
66	14	12	65000.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 12:35:45.853	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
67	15	12	27000.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 12:39:59.811	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
195	63	66	1050.00	12600.00	1050	2	\N	\N	\N	\N	\N				\N	2015-01-07 15:14:20.94	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
69	15	10	125000.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 13:15:41.354	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
70	15	9	12345.00	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2014-11-25 13:39:18.481	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	good	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
196	63	60	1400.00	3080.00	1400	2	\N	\N	\N	\N	\N				\N	2015-01-07 15:15:14.639	\N	\N	\N			f	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
197	63	61	50.00	2700.00	50	2	\N	\N	\N	\N	\N				\N	2015-01-07 15:16:07.428	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
198	63	65	100.00	350.00	100	2	\N	\N	\N	\N	\N				\N	2015-01-07 15:16:51.546	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
199	63	67	500.00	10000.00	1500	1	\N	\N	\N	\N	\N				\N	2015-01-08 09:46:25.895	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
200	63	10	10.00	-10.00	10	1	\N	\N	\N	\N	\N				\N	2015-01-14 13:37:34.864	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
201	66	66	5200.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2015-01-16 09:58:37.372	\N	\N	\N		Al	t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
502	3383	2	10000.00	1000.00	5000	1	\N	\N	\N	\N	\N				\N	2015-11-27 10:37:00.342	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
206	67	57	20000.00	1.50	1	1	\N	\N	\N	\N	\N				\N	2015-01-29 13:51:34.256	\N	\N	\N			t	0	0	0	1	good	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
207	7	2	25000.00	25000.00	1250000	1	\N	\N	\N	\N	\N				\N	2015-01-29 14:49:23.562	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
228	88	1	100.00	100.00	100	1	\N	\N	\N	\N	\N				\N	2015-02-17 13:24:31.703	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
229	91	70	50.00	50.00	50	1	\N	\N	\N	\N	\N				\N	2015-02-18 08:58:27.359	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
230	91	71	60.00	60.00	60	2	\N	\N	\N	\N	\N				\N	2015-02-18 08:59:06.947	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
231	91	72	70.00	70.00	70	1	\N	\N	\N	\N	\N				\N	2015-02-18 08:59:45.347	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Dolar	EP	1	\N	\N	\N
232	91	73	80.00	80.00	80	2	\N	\N	\N	\N	\N				\N	2015-02-18 09:00:16.06	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
233	88	74	30.00	30.00	30	1	\N	\N	\N	\N	\N				\N	2015-02-18 09:37:09.415	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
234	88	75	40.00	40.00	40	1	\N	\N	\N	\N	\N				\N	2015-02-18 09:37:45.129	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
235	88	76	50.00	50.00	50	2	\N	\N	\N	\N	\N				\N	2015-02-18 09:38:20.574	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
236	88	77	60.00	60.00	60	2	\N	\N	\N	\N	\N				\N	2015-02-18 09:38:45.786	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
237	94	2	25000.00	25000.00	50000	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:37:20.034	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
238	94	78	222222.00	111111.00	1111110	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:38:57.548	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
252	96	85	15000000.00	15000000.00	150000000	1	\N	\N	\N	\N	\N				\N	2015-02-25 09:18:53.345	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
219	11	13	32111.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2015-01-30 08:00:20.856	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N
268	98	96	1000.00	14.00	1	2	\N	\N	\N	\N	\N				\N	2015-03-02 08:22:48.811	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
158	10	4	10.00	10.00	10	1	\N	\N	\N	\N	\N				\N	2014-12-04 13:05:47.118	\N	\N	\N			t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
239	94	1	1440.00	1440.00	14400	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:40:07.024	\N	\N	\N			f	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
615	3388	8	1000.00	1000.00	10000	2	\N	\N	\N	\N	\N				\N	2018-10-03 07:34:27.978452	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
616	3415	1	1000.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-10-11 14:15:45.148213	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
617	3414	1	900.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-10-11 14:16:39.266009	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
863	3456	293	38050.00	38000.00	131.810000000000002	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:44:58.838501	\N	\N	\N	Hefe, Malz, und Hopfen aus Fallstudie Ueli	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
931	3459	272	50727.00	12994.00	11.8399999999999999	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-01 18:39:22.007684	\N	\N	\N		\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
855	3457	272	46191.60	14000.00	10.7799999999999994	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:31:57.545657	\N	\N	\N	Strombezug f├╝r Brauerei	\N	t	\N	\N	\N	4	\N	\N	\N	\N	\N	CHF	EP	8	\N	\N	\N
947	3462	301	19000.00	1000.00	83.3299999999999983	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-12-02 18:51:03.323721	\N	\N	\N	Malzkuchenr├╝ckstand	\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
503	3383	1	20.00	40.00	200	1	\N	\N	\N	\N	\N				\N	2015-11-27 10:38:49.985	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
409	3359	66	24000.00	240000.00	1	1	\N	\N	\N	\N	\N				\N	2015-08-11 12:20:48.903	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
245	94	82	22984.00	229840.00	229840000	2	\N	\N	\N	\N	\N				\N	2015-02-24 16:51:53.793	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
247	94	83	91000.00	9100.00	9100	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:54:14.047	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
248	94	84	26000.00	26000.00	260000	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:54:56.748	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
249	94	85	100000.00	-10000000.00	100000	2	\N	\N	\N	\N	\N				\N	2015-02-24 16:56:09.824	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
250	95	82	5000.00	200.00	1110000	2	\N	\N	\N	\N	\N				\N	2015-02-24 17:11:01.761	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
251	94	81	85000.00	0.00	850000	2	\N	\N	\N	\N	\N				\N	2015-02-25 08:08:34.531	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
260	97	90	150000.00	-5000.00	15400	1	\N	\N	\N	\N	\N				\N	2015-02-25 09:47:29.513	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
261	98	57	12000.00	200.00	1	2	\N	\N	\N	\N	\N				\N	2015-02-25 14:47:57.527	\N	\N	\N			t	\N	\N	\N	1	good, wood pieces	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
263	99	57	27000.00	200.00	1	1	\N	\N	\N	\N	\N				\N	2015-02-25 15:05:45.532	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
267	99	95	5000.00	23.00	1	1	\N	\N	\N	\N	\N				\N	2015-02-27 10:18:58.943	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
241	94	79	7680.00	76800.00	7680000	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:43:27.363	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
253	96	86	65000.00	65000000.00	650000000	1	\N	\N	\N	\N	\N				\N	2015-02-25 09:20:06.676	\N	\N	\N			f	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
255	96	87	20000.00	200000.00	2000000	1	\N	\N	\N	\N	\N				\N	2015-02-25 09:24:10.487	\N	\N	\N			f	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
256	96	88	14000000.00	-1400000.00	140000000	2	\N	\N	\N	\N	\N				\N	2015-02-25 09:25:21.569	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
257	96	89	100000.00	-1000.00	10000	2	\N	\N	\N	\N	\N				\N	2015-02-25 09:31:13.075	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
254	96	2	4000000.00	400000.00	40000000	1	\N	\N	\N	\N	\N				\N	2015-02-25 09:23:28.935	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
262	98	66	890.00	280.00	1	1	\N	\N	\N	\N	\N	Company			\N	2015-02-25 15:04:32.859	\N	\N	\N			t	\N	\N	\N	1	good	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
264	99	3	28000.00	120.00	1	2	\N	\N	\N	\N	\N				\N	2015-02-25 15:06:29.904	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
265	98	94	450000.00	0.30	1	1	\N	\N	\N	\N	\N				\N	2015-02-27 09:58:16.817	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
266	99	94	500000.00	0.20	1	2	\N	\N	\N	\N	\N				\N	2015-02-27 09:59:07.36	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
205	68	57	2000.00	1.00	1	2	\N	\N	\N	\N	\N	Geneva			\N	2015-01-29 13:50:22.823	\N	\N	\N			t	0	0	0	1	good	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
269	45	3	11.00	22.00	33	1	\N	\N	\N	\N	\N				\N	2015-03-03 11:30:26.877	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
412	3359	131	12.00	12.00	1	1	\N	\N	\N	\N	\N				\N	2015-08-18 08:33:49.211	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
364	135	137	24000.00	600.00	100	1	\N	\N	\N	\N	\N	Carouge, Geneve	No	Chutes valorisables	\N	2015-05-19 12:54:39.511	\N	\N	\N	Fil de diam├¿tre variable	Cu	t	\N	\N	\N	1	Fil de cuivre	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
272	13	8	123.00	123.00	123	1	\N	\N	\N	\N	\N				\N	2015-03-03 12:07:41.704	\N	\N	\N		112	t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
275	13	10	11.00	11.00	11	1	\N	\N	\N	\N	\N				\N	2015-03-03 12:21:23.207	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
276	13	66	0.00	0.00	0	1	\N	\N	\N	\N	\N				\N	2015-03-03 12:59:06.417	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
277	13	62	0.10	1.00	1	1	\N	\N	\N	\N	\N				\N	2015-03-03 13:00:33.672	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
278	13	4	0.00	0.00	0	1	\N	\N	\N	\N	\N				\N	2015-03-03 13:09:22.143	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
279	99	97	123.00	123.00	123	2	\N	\N	\N	\N	\N				\N	2015-03-03 13:44:58.955	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
281	130	98	1000.00	15000.00	150000	1	\N	\N	\N	\N	\N				\N	2015-03-20 12:15:13.969	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
282	97	99	10000.00	-1000.00	15000	2	\N	\N	\N	\N	\N				\N	2015-03-24 10:48:25.718	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
413	11	24	1000.00	1000.00	1000	2	\N	\N	\N	\N	\N				\N	2015-08-24 11:49:26.83	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Emission
331	7	12	1000.00	1000.00	1000	1	\N	\N	\N	\N	\N	1231da	daddad	sadasdasd	\N	2015-03-27 11:07:40.57	\N	\N	\N	qweqwe	test	f	123	12333	12	2	123	\N	\N	\N	\N	TL	EP	1	kg/m3	Standard atmosphere (atm)	\N
334	7	120	1213.00	123.00	123123	1	\N	\N	\N	\N	\N				\N	2015-03-27 11:15:06.267	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
342	7	122	123.00	123.00	123123	1	\N	\N	\N	\N	\N				\N	2015-03-27 12:26:48.793	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
367	135	140	60000.00	12.00	100	1	\N	\N	\N	\N	\N				\N	2015-05-19 13:02:36.596	\N	\N	\N			t	\N	12	\N	3	Pure	\N	\N	\N	\N	Euro	EP	1	\N	bar (Bar)	\N
352	68	131	20.00	20.00	20	1	\N	\N	\N	\N	\N				\N	2015-04-21 07:40:43.44	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
328	132	103	27675.00	10000.00	125	2	\N	\N	\N	\N	\N				\N	2015-03-27 07:50:55.439	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
326	132	117	1845.00	16605.00	1726	1	\N	\N	\N	\N	\N				\N	2015-03-27 07:40:37.838	\N	\N	\N	contains borron		t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
315	132	69	326.00	6000.00	105	2	\N	\N	\N	\N	\N				\N	2015-03-26 11:39:59.372	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
329	132	109	350.00	180000.00	462	1	\N	\N	\N	\N	\N				\N	2015-03-27 08:09:50.497	\N	\N	\N	made of HHS, price unknown,		t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
325	132	105	462048.00	110891.00	302179	1	\N	\N	\N	\N	\N				\N	2015-03-27 07:20:14.7	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
305	132	112	1000.00	3500.00	905	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:29:56.096	\N	\N	\N	internally lubricated low friction polymers		t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
306	132	112	200.00	200.00	20	2	\N	\N	\N	\N	\N				\N	2015-03-26 11:31:19.215	\N	\N	\N	internally lubricated low friction polymers		t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
307	132	61	400.00	21600.00	2464	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:32:03.531	\N	\N	\N			t	123	12	123	1		\N	\N	\N	\N	TL	EP	1	kg/m3	bar (Bar)	
308	132	61	23.00	3672.00	2.29999999999999982	2	\N	\N	\N	\N	\N				\N	2015-03-26 11:33:01.892	\N	\N	\N			t	1	2	3	1		\N	\N	\N	\N	TL	EP	1	kg/m3	bar (Bar)	
310	132	60	2800.00	7700.00	280	2	\N	\N	\N	\N	\N				\N	2015-03-26 11:34:23.328	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
327	132	103	30750.00	16906.00	138.990000000000009	1	\N	\N	\N	\N	\N				\N	2015-03-27 07:48:55.633	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
309	132	60	14000.00	30800.00	65660	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:33:45.573	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
323	132	114	6.00	600.00	11.6400000000000006	1	\N	\N	\N	\N	\N				\N	2015-03-26 12:51:08.935	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
304	132	66	2100.00	25200.00	1050	2	\N	\N	\N	\N	\N				\N	2015-03-26 11:28:16.136	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
314	132	1	1260.00	13104.00	0.100000000000000006	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:39:17.663	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
318	132	104	12.00	780.00	21.7199999999999989	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:46:16.757	\N	\N	\N	Packaging		t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
313	132	98	12000.00	15000.00	28080	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:38:42.925	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	TL	EP	1	\N	\N	
321	132	108	1000.00	2500.00	323	2	\N	\N	\N	\N	\N				\N	2015-03-26 11:48:27.812	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
243	95	60	420000.00	546000.00	107000000	1	\N	\N	\N	\N	\N			Weights of the selled machines	\N	2015-02-24 16:47:47.049	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
411	3358	5	1.40	0.00	0.135000000000000009	1	\N	\N	\N	\N	\N			virtual input to balance reported output of copper waste, EP=Gpt UBP 2013	\N	2015-08-12 14:02:27.327	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
410	3358	4	0.80	0.00	0.0845000000000000057	1	\N	\N	\N	\N	\N			virtual input to balance reported output of brass waste, EP=Gpt UBP 2013	\N	2015-08-12 13:59:21.551	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
203	68	66	21500000.00	0.00	0	1	\N	\N	\N	\N	\N				\N	2015-01-16 10:04:53.455	\N	\N	\N		Al	t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
368	135	140	20000.00	12.00	100	2	\N	\N	\N	\N	\N				\N	2015-05-19 13:06:14.336	\N	\N	\N			t	\N	\N	\N	2	Hot water, around 60 degrees	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
370	136	139	80000.00	4.00	100	1	10.10	1	2.00	1	\N	asdasdad 	dasdasd ddasd		dddasssssssssssss 3 	2015-05-19 13:13:03.556	\N	\N	\N			t	\N	\N	\N	1		11.50	1	14.30	1	Euro	EP	1	\N	\N	\N
365	135	137	1200.00	250.00	100	2	\N	\N	\N	\N	\N	Carouge, Geneve	Pour recyclage		\N	2015-05-19 12:58:15.331	\N	\N	\N		Cu	t	\N	\N	\N	1	Chutes de fil de cuivre, non souill├®	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
369	135	66	4000.00	340.00	100	2	\N	\N	\N	\N	\N				\N	2015-05-19 13:08:29.187	\N	\N	\N	Chutes pour recyclage	Al	t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
374	137	142	10000000.00	35.00	100	1	\N	\N	\N	\N	\N		No		\N	2015-05-19 13:20:12.137	\N	\N	\N			t	\N	\N	\N	1	Bonne	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
375	137	142	1200000.00	10.00	100	2	\N	\N	\N	\N	\N	Bardonnex, Gen├¿ve	Oui, comme grave ├á b├®ton		\N	2015-05-19 13:21:26.614	\N	\N	\N			t	\N	\N	\N	1	Argile cuit, chutes de production	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
380	139	3	123.00	123.00	123	1	\N	\N	\N	\N	\N				\N	2015-05-26 09:18:54.807	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
376	137	140	300000.00	80.00	100	2	\N	\N	\N	\N	\N	Bardonnex, Gen├¿ve			\N	2015-05-19 13:22:27.739	\N	\N	\N		H2O	t	\N	1	\N	2	Condensat ├á 60┬░C	\N	\N	\N	\N	Euro	EP	1	\N	bar (Bar)	\N
378	138	143	42000000.00	45.00	100	1	\N	\N	\N	\N	\N				\N	2015-05-19 13:26:09.516	\N	\N	\N			t	\N	\N	\N	1	Selon calibrage	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
379	138	144	300000.00	2.50	100	1	\N	\N	\N	\N	\N				\N	2015-05-19 13:26:47.252	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
377	138	142	18000000.00	40.00	100	1	\N	\N	\N	\N	\N				\N	2015-05-19 13:25:25.833	\N	\N	\N			t	\N	\N	\N	1	Concass├®	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
366	135	139	2000.00	60.00	100	2	\N	\N	\N	\N	\N				\N	2015-05-19 13:00:27.942	\N	\N	\N	Wood pallets		t	\N	\N	\N	1	Bonne	\N	\N	\N	\N	Euro	EP	1	\N	\N	\N
381	10	8	11.00	11.00	11	1	\N	\N	\N	\N	\N	11	11	11	\N	2015-06-01 19:28:46.458	\N	\N	\N	11	11	t	11	11	11	2	11	\N	\N	\N	\N	Dolar	EP	1	kg/m3	Pascal (Pa)	\N
384	94	145	212.00	212.00	1120096	1	\N	\N	\N	\N	\N				\N	2015-06-10 11:44:16.626	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	\N
400	3358	89	12.50	0.00	0	2	\N	\N	\N	\N	\N			no costs	\N	2015-07-15 14:01:35.851	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
391	3358	147	80.00	850.00	0	1	\N	\N	\N	\N	\N				\N	2015-07-15 13:17:57.352	\N	\N	\N		mixed cleaners	f	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
392	3358	148	1200.00	10000.00	0	1	\N	\N	\N	\N	\N				\N	2015-07-15 13:19:43.937	\N	\N	\N			f	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
371	136	137	6000000.00	250.00	100	1	20.10	1	3.00	1	\N	asdasdad 	dasdasd ddasd		dddasssssssssssss 3 	2015-05-19 13:13:47.864	\N	\N	\N		Cu	t	\N	\N	\N	1	Suffisante pour fonderie	21.50	1	24.30	1	Euro	EP	1	\N	\N	\N
324	132	114	1.00	500.00	2.5	2	\N	\N	\N	\N	\N				\N	2015-03-26 12:52:32.224	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	
398	3358	90	18.50	4100.00	0.00610999999999999998	2	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 13:57:11.004	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
303	132	66	10500.00	126000.00	80850	1	\N	\N	\N	\N	\N				\N	2015-03-26 11:27:22.659	\N	\N	\N			t	12	\N	\N	1		\N	\N	\N	\N	TL	EP	1	%	\N	
387	3358	146	83500.00	8400.00	0.394000000000000017	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 12:48:40.848	\N	\N	\N	Energieinhalt 36MJ/l, Dichte 840kg/m3		f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
390	3358	114	400.00	800.00	0.00101000000000000005	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 13:13:35.063	\N	\N	\N	Dichte (20 ┬░C) 0.810 = 810 g/l	nitro-cellulose combination thinner	f	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
396	3358	150	20.00	8000.00	0	1	\N	\N	\N	\N	\N			pieces = rolls	\N	2015-07-15 13:41:04.383	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
397	3358	151	16.00	0.00	0.000754000000000000004	1	\N	\N	\N	\N	\N			price not alvaliable, EP =GPt UBP 2013	\N	2015-07-15 13:50:32.437	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
401	3358	57	30.00	2900.00	0	2	\N	\N	\N	\N	\N				\N	2015-07-15 14:02:07.321	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
395	3358	57	130.68	264000.00	0.0529000000000000026	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 13:38:55.383	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
388	3358	66	50.00	300000.00	1.98999999999999999	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 12:51:42.727	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
403	3358	66	0.40	-350.00	0	2	\N	\N	\N	\N	\N				\N	2015-07-15 14:05:10.245	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
405	3358	4	0.80	-2190.00	0	2	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 14:08:55.046	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
394	3358	149	3840.00	15000.00	0.00730999999999999966	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 13:32:19.533	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
406	3358	5	1.40	-2000.00	0	2	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 14:10:27.106	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
386	3358	2	885545.00	123000.00	0.267000000000000015	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 12:42:35.707	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
402	3358	153	0.20	0.00	0	2	\N	\N	\N	\N	\N			no costs, seperate collection	\N	2015-07-15 14:04:26.538	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
407	3358	151	16.00	2300.00	0	2	\N	\N	\N	\N	\N				\N	2015-07-15 14:11:30.402	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
389	3358	87	600.00	1500.00	0	1	\N	\N	\N	\N	\N				\N	2015-07-15 12:52:55.394	\N	\N	\N			f	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
399	3358	152	14.20	6300.00	0.0415000000000000022	1	\N	\N	\N	\N	\N			EP =GPt UBP 2013	\N	2015-07-15 13:58:50.388	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
393	3358	1	1095.00	9500.00	0.000558000000000000011	1	\N	\N	\N	\N	\N			for cooling, EP =GPt UBP 2013	\N	2015-07-15 13:20:36.714	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
404	3358	60	200.00	-27300.00	0	2	\N	\N	\N	\N	\N				\N	2015-07-15 14:05:50.263	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
372	136	66	6000000.00	250.00	100	1	30.10	1	3.00	1	\N	asdasdad 	dasdasd ddasd		dddasssssssssssss 3 	2015-05-19 13:14:39.664	\N	\N	\N		Al	t	\N	\N	\N	1	Suffisante pour fonderie	31.50	1	34.30	1	Euro	EP	1	\N	\N	\N
373	136	141	2000000.00	30.00	100	1	40.10	1	4.00	1	\N	asdasdad 	dasdasd ddasd		dddasssssssssssss 3 	2015-05-19 13:16:17.771	\N	\N	\N			t	99	\N	\N	2	Contient des impuret├®s organiques	41.50	1	44.30	1	Euro	EP	1	%	\N	\N
414	3362	154	1000.00	1000.00	100	1	\N	\N	\N	\N	\N				\N	2015-09-01 07:07:35.461	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Dollar	EP	1	\N	\N	
415	3362	155	2000.00	1000.00	10	1	\N	\N	\N	\N	\N				\N	2015-09-01 07:08:18.774	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
416	3362	156	500.00	500.00	120	1	\N	\N	\N	\N	\N				\N	2015-09-01 07:10:02.207	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
417	3362	157	100.00	450.00	100	1	\N	\N	\N	\N	\N				\N	2015-09-01 07:10:58.592	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
418	3362	158	100.00	100.00	10	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:15:04.064	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
419	3362	159	200.00	200.00	20	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:24:10.899	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
420	3362	160	70.00	1.00	20	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:30:09.291	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
421	3362	161	1000.00	1000.00	25	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:31:28.633	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
355	134	98	640000.00	70400.00	120.099999999999994	1	\N	\N	\N	\N	\N			UBP 2013, MPT, Gas Heating CH  EP = MPt. UBP, 45.8 UBP/MJ, Cost are estimated as no data was avaliabe (0.11 CHF/kWh according to http://www.energiezukunftschweiz.ch/5_-_WKK_Schweiz__Markus_Erb.pdf, Slide 9)	\N	2015-04-29 15:36:30.588	\N	\N	\N	Gas Heating		f	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	
359	134	89	431.50	-26000.00	1600	2	\N	\N	\N	\N	\N			UBP 2013, MPT, dito Input, EP/ton. EP = MPt. UBP rough estimation (3.7 MPt/to), price  for waste paper 0.06Ôé¼/kg from internet	\N	2015-05-06 13:54:32.971	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
356	134	85	14381.00	9347650.00	22578.1699999999983	1	\N	\N	\N	\N	\N			UBP 2013, MPT, graphic paper 100% recycled (GLO). Costs in CHF, EP= kPt. UBP, 1.190 MPt /to, delivery by train, weight paper 50g/m2 --&gt;  287'620'000 m2	\N	2015-04-29 15:41:43.261	\N	\N	\N			f	\N	\N	\N	1	partly FSC zertified, all 95% recycling content	\N	\N	\N	\N	CHF	EP	1	\N	\N	
383	134	69	3200.00	9600.00	13.5999999999999996	2	\N	\N	\N	\N	\N			UBP 2013, MPT, Wastewater average (CH), treatement of, capacitiy 1.6E8l/year.	\N	2015-06-04 09:24:25.817	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
382	134	1	3200.00	3200.00	0.0735999999999999988	1	\N	\N	\N	\N	\N			UBP 2013, MPT, water unspecified natural origin, CH.	\N	2015-06-04 09:15:37.75	\N	\N	\N		H20	t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
422	3362	162	1000.00	200.00	30	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:32:43.698	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Emission
423	3362	163	500.00	500.00	100	1	\N	\N	\N	\N	\N				\N	2015-09-01 07:33:46.196	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	
424	3362	164	100.00	100.00	10	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:34:59.794	\N	\N	\N	kanalizasyona geri veriliyor		t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
425	3362	165	100.00	130.00	26	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:35:56.4	\N	\N	\N	tamam─▒ geri d├Ân├╝┼şt├╝r├╝l├╝yor. Di┼ş a├ğma'da kesme ya─ş─▒ olarak kullan─▒l─▒yor		t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
426	3362	166	30.00	300.00	57	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:36:58.651	\N	\N	\N	yak─▒lam─▒yor. ba┼şka bir firmaya veriyorlar.		t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
427	3362	167	700.00	700.00	70	2	\N	\N	\N	\N	\N				\N	2015-09-01 07:48:14.307	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
428	3362	168	700.00	700.00	70	2	\N	\N	\N	\N	\N				\N	2015-09-01 08:40:34.01	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
429	3362	169	700.00	700.00	70	2	\N	\N	\N	\N	\N				\N	2015-09-01 08:44:07.249	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
430	3362	170	200.00	450.00	45	1	\N	\N	\N	\N	\N				\N	2015-09-01 08:44:57.96	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	TL	EP	1	\N	\N	
431	3362	171	700.00	700.00	70	2	\N	\N	\N	\N	\N				\N	2015-09-01 08:46:02.555	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
432	3362	172	700.00	700.00	70	2	\N	\N	\N	\N	\N				\N	2015-09-01 08:46:59.749	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
433	3362	173	700.00	70.00	70	2	\N	\N	\N	\N	\N				\N	2015-09-01 08:50:19.444	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Recycling
434	3362	174	1000.00	1000.00	100	1	\N	\N	\N	\N	\N				\N	2015-09-01 08:51:24.332	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
436	7	24	123.00	123.00	123	1	\N	\N	\N	\N	\N				\N	2015-09-02 12:45:07.405	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Emission
437	7	129	123.00	123.00	123	1	\N	\N	\N	\N	\N				\N	2015-09-02 12:54:51.823	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
246	95	2	885545.00	123000.00	14320000	1	\N	\N	\N	\N	\N				\N	2015-02-24 16:53:37.755	\N	\N	\N	14-15 Rp/kWh, Electricity mix from EW Gossau / Electricity from machining process: between 23'500kWh to 48'000kWh = 2.5%-5.5% from the total of Electricity		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
450	95	148	1200.00	10000.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 13:03:58.929	\N	\N	\N	CNC-Constructions with a central cooling-construction		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
453	95	179	20.00	8000.00	0	1	\N	\N	\N	\N	\N			Unit = roll	\N	2015-09-03 13:23:37.637	\N	\N	\N			t	\N	\N	\N	1	Cushion	\N	\N	\N	\N	CHF	EP	1	\N	\N	
444	95	175	4000.00	6000.00	0	1	\N	\N	\N	\N	\N	400W	In Winter/Spring 2016 they will changed all Metal-halide lamps to LED.		\N	2015-09-03 12:25:51.913	\N	\N	\N	150piece/400W in the assembly hall with 4000m2		t	\N	\N	\N	1	Metal-halide lamp	\N	\N	\N	\N	Euro	EP	1	\N	\N	
445	95	176	6721.00	3560.00	0	1	\N	\N	\N	\N	\N	58W	Changing to LED	1'360m2 Neon tubes in storehouse, 4'000m2 Neon tubes in cellar, 1'360m2 Neon tubes in office	\N	2015-09-03 12:45:42.19	\N	\N	\N	400pieces/58W on 6'721m2		t	\N	\N	\N	1	Neon tube	\N	\N	\N	\N	CHF	EP	1	\N	\N	
449	95	147	80.00	850.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 13:00:47.093	\N	\N	\N			t	\N	\N	\N	1	Mix Nitro diluter	\N	\N	\N	\N	CHF	EP	1	\N	\N	
448	95	114	400.00	800.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 13:00:01.558	\N	\N	\N			t	\N	\N	\N	2	Mix Nitro diluter	\N	\N	\N	\N	CHF	EP	1	\N	\N	
467	95	151	16000.00	2300.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:22:29.857	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
454	95	151	16000.00	2300.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 13:45:08.851	\N	\N	\N	Laser drilling sand		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
451	95	1	1095.00	9500.00	0	1	\N	\N	\N	\N	\N			Cooling water, including subtenant	\N	2015-09-03 13:05:39.297	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
443	95	99	83500.00	8400.00	0	1	\N	\N	\N	\N	\N		Connecting from old to new parts of the building		\N	2015-09-03 12:02:00.286	\N	\N	\N	Heating oil, without warm water		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
452	95	178	1200.00	264000.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 13:17:19.211	\N	\N	\N	2800x450x450x20mm = <0.1089m3/wooden box		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
470	3365	182	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 08:43:45.702	\N	\N	\N	Heat from cooling system &#40;25┬░C-35┬░C&#41;		t	\N	\N	\N	3		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
455	95	90	18500.00	4100.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 13:48:31.607	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
456	95	152	14200.00	6300.00	0	2	\N	\N	\N	\N	\N		Cutting-Oil dry machining		\N	2015-09-03 13:54:47.795	\N	\N	\N	Big part of this waste is the cooling emulsion. A little part takes the waste from electronic srap and and paint.		t	\N	\N	\N	2	Cooling emulsion	\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
457	95	180	5000.00	15000.00	0	1	\N	\N	\N	\N	\N			Rating  c = 3840kg for all 5000 units	\N	2015-09-03 13:59:36.616	\N	\N	\N	600x400x400mm = 1.28m2/unit		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
458	95	87	600.00	1500.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 14:01:44.995	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
459	95	180	12500.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:02:57.832	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
460	95	57	30000.00	2900.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:04:57.045	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
461	95	179	200.00	0.00	0	2	\N	\N	\N	\N	\N			disposal of waste separately	\N	2015-09-03 14:07:37.616	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
462	95	66	50000.00	300000.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-03 14:12:13.558	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
463	95	66	400.00	-350.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:13:33.69	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
464	95	60	200000.00	-27300.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:18:05.509	\N	\N	\N			t	\N	\N	\N	1	160t to 180t cuttings and 500kg to 1200kg/piece of heavy rolls	\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
465	95	4	800.00	-2190.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:19:58.509	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
466	95	5	1400.00	-2000.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-03 14:21:04.841	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
469	3365	181	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 08:42:28.495	\N	\N	\N	Heat from industrial waste water (20┬░C - 50┬░C)		t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
471	3366	181	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 08:46:01.334	\N	\N	\N	Heat from industrial waste water (20┬░C)		t	\N	\N	\N	2		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
473	3367	181	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 08:53:37.955	\N	\N	\N	Heat from industrial waste water (20┬░C)		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
474	3367	182	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 08:54:18.503	\N	\N	\N	Heat from cooling system &#40;25┬░C-35┬░C&#41;		t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
475	3367	69	100.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-04 08:55:38.03	\N	\N	\N	treated water		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
477	3368	99	100.00	0.00	0	1	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 09:19:21.416	\N	\N	\N	Use for greenhouses heating		t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
479	3369	99	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 10:12:46.574	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
480	3370	99	100.00	0.00	0	1	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 12:20:38.138	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
481	3371	151	100.00	0.00	0	2	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-04 12:43:46.384	\N	\N	\N	Foundry sand		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
482	138	151	100.00	0.00	0	1	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-04 12:47:09.032	\N	\N	\N	Foundry sand		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
830	3453	284	1.00	12.50	15700	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-19 12:22:29.440151	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	30	\N	\N	\N
483	137	185	100.00	0.00	0	2	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-04 12:51:27.81	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
485	66	87	100.00	0.00	0	2	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 13:53:55.26	\N	\N	\N	used solvents		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
486	66	186	100.00	0.00	0	2	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 13:55:04.627	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
487	135	151	100.00	0.00	0	2	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-04 14:52:08.619	\N	\N	\N	Foundry sand		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
488	3374	187	100.00	0.00	0	2	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 15:04:00.446	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
489	3375	188	100.00	0.00	0	1	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 15:12:08.792	\N	\N	\N	construction waste		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
491	3376	183	100.00	0.00	0	1	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-07 14:45:43.937	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
492	3365	187	100.00	0.00	0	1	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-07 14:53:44.792	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
476	3365	183	1.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2015-09-04 08:58:00.659	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
202	67	66	2400.00	0.00	0	2	\N	\N	\N	\N	\N				\N	2015-01-16 10:02:04.969	\N	\N	\N		Al	t	0	0	0	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
493	3358	60	200.00	0.00	0.857999999999999985	1	\N	\N	\N	\N	\N			virtual input to balance reported output of steel waste, EP=Gpt UBP 2013	\N	2015-09-09 13:59:18.532	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
494	3358	85	8660.00	0.00	0.0208999999999999984	1	\N	\N	\N	\N	\N			virtual input to balance reported output of paper waste, EP=Gpt UBP 2013	\N	2015-09-09 14:03:56.052	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
495	132	107	100.00	1500.00	590	2	\N	\N	\N	\N	\N				\N	2015-09-11 11:38:52.984	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
496	96	3	50.00	15000.00	0	2	\N	\N	\N	\N	\N			TEST	\N	2015-09-14 08:25:25.014	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
472	3366	182	100.00	0.00	0	2	\N	\N	\N	\N	\N			Source: "Synergies ├®nerg├®tiques dans la ZIPLO et la zone maraich├¿re de la plaine de l'Aire, projet Ecosite, Rapport d'├®tude juillet 2007, Enercore"	\N	2015-09-04 08:46:50.593	\N	\N	\N	Heat from cooling system &#40;25┬░C-35┬░C&#41;		t	\N	\N	\N	3		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
478	3369	184	12000000.00	0.00	0	1	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-04 09:46:23.54	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
497	3378	184	10000.00	0.00	0	2	\N	\N	\N	\N	\N			source: "5 ans de travaux en ├®cologie industrielle : r├®sultats et perspectives, may 2015, Sofies	\N	2015-09-17 13:57:45.445	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
498	3373	87	100.00	0.00	0	1	\N	\N	\N	\N	\N			source: brochure Ecologie Industrielle	\N	2015-09-17 15:08:30.693	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	Recycling
499	3379	142	123.00	100.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-21 15:17:27.114	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
500	141	8	78.00	7887.00	7887	2	\N	\N	\N	\N	\N				\N	2015-09-23 13:26:09.985	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Emission
501	3382	183	100.00	0.00	0	1	\N	\N	\N	\N	\N				\N	2015-09-28 08:54:52.028	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
504	3383	5	5000.00	1000.00	4000	1	\N	\N	\N	\N	\N				\N	2015-12-17 18:44:09.173	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
484	3372	185	200.00	0.00	0	1	\N	\N	\N	\N	\N			source: Les symbioses industrielles : une nouvelle strate╠ügie pour lÔÇÖame╠ülioration de lÔÇÖutilisation des ressources mate╠ürielles et e╠ünerge╠ütiques par les activite╠üs e╠üconomiques, 2011, Th├¿se de doctorat, Guillaume Massard"	\N	2015-09-04 12:54:56.705	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
510	3388	190	11000.00	5000.00	2.69499999999999984	2	\N	\N	\N	\N	\N			Environmental impact in MPt UBP:  Treatment with HCL and NaOH for dewatering to 30%. 1 L 0.000245 MPt	\N	2016-03-11 06:06:03.598	\N	\N	\N	90% water, 10% cutting fluid		t	10	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	%	\N	
506	3383	189	10.00	10000.00	2000	1	\N	\N	\N	\N	\N				\N	2016-03-09 16:28:22.16	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
357	134	86	284.00	1000000.00	903.120000000000005	1	\N	\N	\N	\N	\N			UBP 2013, MPT, printing colour offset, 47.5% solvent at plant (RER). Cost in CHF, EP = MPt. UBP rough estimation (4.66 MPt/to)	\N	2015-04-29 15:57:47.521	\N	\N	\N	180 t colors , 104 t black purched in 2014		f	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
353	134	2	2900000.00	367720.00	88.7000000000000028	1	\N	\N	\N	\N	\N			UBP 2013, MPT, Electricity medium voltage CH, market for. Cost are actually in CHF, EP=MPt. UBP (UBP 2006: 88.74) for mix of different Hydropowerplants according to http://www.bfe.admin.ch/themen/00490/00491/ ( 47,4 % Laufwasserkraftwerken, 48,2 % Speicherkraftwerken, 4,4 % Pumpspeicherkraftwerken) --&gt; 30.6 UBP/kWh	\N	2015-04-29 15:16:04.418	\N	\N	\N			f	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
509	3388	1	1095.00	4500.00	0.599999999999999978	1	\N	\N	\N	\N	\N			Environmental impact in MPt UBP: 1 m3 water = 0.000510 MPt	\N	2016-03-11 05:53:35.766	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
508	3388	103	1200.00	9960.00	2.496	1	\N	\N	\N	\N	\N			Environmental impact in MPt UBP: 1 L Lubrication oil = 0.00208 MPt	\N	2016-03-11 05:47:13.175	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
511	3389	191	1710.00	615600.00	0	1	\N	\N	\N	\N	\N	Product			\N	2016-03-11 13:21:43.946	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
512	3389	192	3395000.00	169750.00	0	1	\N	\N	\N	\N	\N	Product			\N	2016-03-11 14:09:09.323	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Recycling
513	3389	193	83.00	83000.00	0	1	\N	\N	\N	\N	\N				\N	2016-03-11 14:36:38.84	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	Waste
514	3389	194	2100.00	2100.00	0	1	\N	\N	\N	\N	\N	Product			\N	2016-03-11 14:53:08.696	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
515	3389	195	2771.00	554.00	0	1	\N	\N	\N	\N	\N				\N	2016-03-11 15:33:25.147	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Recycling
519	3391	3	100.00	100.00	1	1	\N	\N	\N	\N	\N				\N	2016-04-13 09:46:50.071	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	TL	EP	1	\N	\N	
524	3390	200	15900.00	6900000.00	31800	1	\N	\N	\N	\N	\N			EP safety glass estimated 2 MPt/ton UBP 2013	\N	2016-05-16 20:00:03.882	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
538	3396	61	76.00	3630.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 13:46:58.457	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
526	3390	196	1500.00	0.00	1575	2	\N	\N	\N	\N	\N			EP flat glass 1.05 MPt/ton UBP	\N	2016-05-16 20:22:01.801	\N	\N	\N	Trimmed glass;  will be returned to float glass factory; No costs for company		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
360	134	133	38624.00	-35000.00	21.8000000000000007	2	\N	\N	\N	\N	\N			UBP 2013, MPT, price scrap alu  0.8Ôé¼/kg from internet, Aluminium scrap, post-consumer, prepared for melting {RER}| treatment of aluminium scrap, post-consumer, by collecting, sorting, cleaning, pressing 565 pt/kg	\N	2015-05-06 14:00:09.005	\N	\N	\N	Aluminium sheet 1mm thickness covered with a laquer	AlMg	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
583	3405	85	6523.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-16 09:49:26.60373	\N	\N	\N	Kraft paper (products)		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
358	134	132	38624.00	700000.00	610.294999999999959	1	\N	\N	\N	\N	\N	0	0	UBP 2013: 15.8 kPt/kg  Angaben in MP	\N	2015-05-06 13:05:14.558	\N	\N	\N	Electrochemically grained and anodized aluminum substrate. Supplier Kodak	AlMg3	t	\N	\N	\N	1	0	\N	\N	\N	\N	CHF	EP	1	\N	\N	
525	3390	200	3000.00	0.00	6000	2	\N	\N	\N	\N	\N			EP safety glass estimated 2 MPt/ton UBP 2013	\N	2016-05-16 20:19:10.662	\N	\N	\N	Trimmed glass;  will be returned to float glass factory; No costs for company		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
522	3390	199	40.00	12000.00	127	2	\N	\N	\N	\N	\N			EP not used ressource Polybutadien = 3.18 MPt/ton UBP 2013	\N	2016-05-16 12:20:30.283	\N	\N	\N	High waste volume due large variation of spacers in color and dimension and minimum lenght to operate production machine	Polybutadien	t	\N	\N	\N	1	T-profile of different lenghts	\N	\N	\N	\N	CHF	EP	1	\N	\N	
523	3390	150	330.00	3300000.00	1000	1	\N	\N	\N	\N	\N			EP Polyvinylchloride, bulk polymerised = 2.96 MPt/t UBP 2013	\N	2016-05-16 13:30:29.964	\N	\N	\N	PVB foil for safety glass lamination	Polyvinyl butyral	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
527	3393	66	10.00	500.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-17 13:54:51.11	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Recycling
507	3388	2	885545.00	123000.00	246	1	\N	\N	\N	\N	\N			EP in Swiss electricity mix = 0.278 MPt/MWh	\N	2016-03-11 05:27:50.668	\N	\N	\N	Electricity mix EW St. Gallen basic,60% water, 30% nuclear, 10% MSWI		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
540	3396	206	13.00	630.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 13:53:36.452	\N	\N	\N		NaOH	t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
541	3396	207	85.00	1840.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 13:56:10.611	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
528	3394	8	17432.00	5000.00	38890792	1	\N	\N	\N	\N	\N				\N	2016-05-18 08:45:05.926	\N	\N	\N	for 1 kg acetone 2,231 kg CO2 eq/unit, EP (Global Warmin Potential IPPC) 2007, for 1 ton 2231 kg CO2 eq/unit, for 17432*2231=38890792	C3H6O	t	100	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	%	\N	
517	3390	196	11044.00	4800000.00	11596	1	\N	\N	\N	\N	\N			EP flat glass  1.05 MPt/ton UBP	\N	2016-04-12 11:44:51.072	\N	\N	\N	Insulation Glass (ISO)		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
520	3393	2	500.00	100.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-11 08:06:49.073	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
531	3394	202	9.70	6000.00	27781	1	\N	\N	\N	\N	\N				\N	2016-05-18 14:13:48	\N	\N	\N	alkyd paint, white, 60% in solvent, 2,864 kg CO2 eq/unit		t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
532	3394	2	5187800.00	100000.00	581034	1	\N	\N	\N	\N	\N				\N	2016-05-18 14:20:33.609	\N	\N	\N	=0,112kg CO2 eq/unit *5187800		t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
521	3390	198	192.00	1100000.00	610	1	\N	\N	\N	\N	\N			EP Polybutadien = 3.18 MPt/ton UBP 2013, weight per meter about 128 g	\N	2016-05-16 12:06:59.373	\N	\N	\N	T-Profil Polybutadien size 8 to 25mm x 8mm,  1500000 m/year		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
533	3394	203	22994.20	15000.00	48890792	1	\N	\N	\N	\N	\N				\N	2016-05-18 14:30:58.743	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
530	3394	201	6355.00	10000.00	3000000	1	\N	\N	\N	\N	\N				\N	2016-05-18 11:27:30.426	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
534	3394	204	2302000.00	50000.00	257824	1	\N	\N	\N	\N	\N				\N	2016-05-18 14:39:46.585	\N	\N	\N	=0,112*2302000 kg CO2 eq/unit		t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
563	3396	210	366.00	347700.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 20:53:28.82	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
537	3396	202	9.90	66300.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 13:39:20.554	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	
548	3396	105	22840700.00	3876799.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 20:17:35.724	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
549	3396	99	58437600.00	1460940.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 20:19:53.869	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
550	3396	1	76876.00	64543.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 20:22:02.677	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	
553	3396	1	26232.00	10530.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:30:53.164	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
542	3396	208	80.00	205730.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 20:07:17.019	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
555	3396	207	85.00	17000.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:35:02.696	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
556	3396	105	1070000.00	181900.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:35:55.628	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
557	3396	99	5815000.00	145375.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:37:08.684	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
539	3396	205	198.00	639540.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-25 13:50:09.162	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	
535	3396	8	17432.00	15932848.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-23 11:21:21.999	\N	\N	\N		C3H6O	t	100	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	%	\N	
552	3396	8	15568.00	14229152.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:24:30.804	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	Euro	EP	1	\N	\N	Recycling
536	3396	201	5688.00	14731920.00	0	1	\N	\N	\N	\N	\N				\N	2016-05-23 11:22:50.507	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	
551	3396	201	666.00	1724940.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:23:18.348	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Recycling
554	3396	208	80.00	128000.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:32:16.843	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
558	3396	205	2.00	1614.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:44:06.046	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
559	3396	202	0.20	40.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:45:19.741	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
560	3396	206	13.00	1950.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:46:21.124	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
561	3396	61	1.50	5445.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:47:33.922	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Emission
564	3396	210	44.00	8800.00	0	2	\N	\N	\N	\N	\N				\N	2016-05-25 20:54:05.213	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Waste
565	3398	211	343.00	23433.00	345	2	\N	\N	\N	\N	\N				\N	2016-09-01 10:37:37.308	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	Euro	EP	1	\N	\N	Emission
566	3402	8	1000.00	10000.00	0	1	\N	\N	\N	\N	\N				\N	2018-03-28 13:11:31.183399	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
567	3401	212	100.00	200.00	0	2	\N	\N	\N	\N	\N				\N	2018-03-28 13:32:55.734846	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Emission
569	3403	1	1632.00	32640.00	0	1	\N	\N	\N	\N	\N	Waste water pipes			\N	2018-07-19 15:38:33.668015	\N	\N	\N		H2O	t	\N	1	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	Standard atmosphere (atm)	
573	3390	182	1000000.00	0.00	278	2	\N	\N	\N	\N	\N				\N	2018-07-31 08:42:10.222194	\N	\N	\N	Waste heat from quenching		t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
570	3403	69	1632.00	0.00	0	2	\N	\N	\N	\N	\N	Waste water pipes			\N	2018-07-19 15:41:53.765919	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
568	3403	98	216000.00	17280.00	0	1	\N	\N	\N	\N	\N	Burned for heating	Fuel tank		\N	2018-07-19 15:35:45.706451	\N	\N	\N			t	\N	2	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	bar (Bar)	
571	3404	182	2000000.00	0.00	0	2	\N	\N	\N	\N	\N	Air evacuation on the roof			\N	2018-07-20 12:02:32.888623	\N	\N	\N			t	\N	1	\N	3	45┬░C	\N	\N	\N	\N	CHF	EP	1	\N	Standard atmosphere (atm)	Waste
572	3404	2	1000000.00	180000.00	0	1	\N	\N	\N	\N	\N				\N	2018-07-20 12:13:08.548424	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
516	3390	2	6900000.00	800000.00	1918	1	\N	\N	\N	\N	\N			EP Swiss electricity mix = 0.278 MPt/MWh	\N	2016-04-12 11:38:25.894	\N	\N	\N	Electricity mix EW St. Gallen basic,60% water, 30% nuclear, 10% MSWI		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
574	3406	184	98267.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-15 14:41:06.40723	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Waste
575	3406	2	14201100.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-15 14:42:47.7228	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
576	3406	1	57820.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-15 14:43:38.698063	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
577	3406	78	8967803.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-15 14:47:21.427856	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
580	3407	2	327070.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-15 14:58:01.655199	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
579	3407	26	30.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-15 14:56:54.550155	\N	\N	\N	Jam (output)		t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
578	3407	24	957125.00	1.00	0	2	\N	\N	\N	\N	\N				\N	2018-08-15 14:54:51.466383	\N	\N	\N	Juice (output)		t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
581	3407	1	15555.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-15 14:58:35.896551	\N	\N	\N			t	\N	\N	\N	2		\N	\N	\N	\N	CHF	EP	1	\N	\N	
582	3407	98	18.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-08-15 14:59:32.82768	\N	\N	\N			t	\N	\N	\N	3		\N	\N	\N	\N	CHF	EP	1	\N	\N	
621	3416	213	10.00	100000.00	21000000	2	\N	\N	\N	\N	\N				\N	2018-10-16 13:07:08.156149	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
622	3416	99	12000.00	50000.00	3000000	2	\N	\N	\N	\N	\N				\N	2018-10-16 13:07:53.290245	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	Recycling
620	3417	69	10000000.00	4500.00	20000	2	\N	\N	\N	\N	\N				\N	2018-10-16 12:13:23.998634	\N	\N	\N	fatty acids in wastewater		t	12	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	%	\N	Waste
623	3416	1	5000000.00	33000.00	121111	1	\N	\N	\N	\N	\N				\N	2018-10-22 11:27:06.030345	\N	\N	\N		H2O	t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
624	3413	214	1.00	1.00	0	1	\N	\N	\N	\N	\N				\N	2018-10-22 12:00:57.678439	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	1	\N	\N	
734	3431	236	62600.00	135200.00	446	2	\N	\N	\N	\N	\N				\N	2019-04-08 15:03:57.601099	\N	\N	\N			t	\N	\N	\N	1		\N	\N	\N	\N	CHF	EP	20	\N	\N	\N
831	3453	6	700.00	80000.00	11900000	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-08-19 12:22:59.503698	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	2	\N	\N	\N
856	3458	293	38050.00	7414.80	131.810000000000002	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2020-10-29 08:32:13.942937	\N	\N	\N		\N	t	\N	\N	\N	1	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
864	3458	275	540.00	5262.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-10-29 08:45:44.343114	\N	\N	\N		\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
932	3459	290	905893.00	23454.00	16.3500000000000014	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 18:40:49.662751	\N	\N	\N	Heizenergie	\N	t	\N	\N	\N	3	\N	\N	\N	\N	\N	CHF	EP	6	\N	\N	\N
936	3459	275	540.00	5000.00	0.689999999999999947	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-01 20:22:28.136315	\N	\N	\N	Reinigungsmittel	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
948	3467	301	40000.00	10000.00	84.2099999999999937	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2020-12-02 18:52:50.330045	\N	\N	\N	N├ñhrstoffquelle f├╝r Bioreaktor, Isolation von Inhaltsstoffen	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	CHF	EP	3	\N	\N	\N
988	3478	320	10000000.00	10000.00	9.19999999999999929	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-24 05:07:33.74056	\N	\N	\N	Alkaline wastewater from concrete production /cleaning	\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	Euro	\N	3	\N	\N	\N
987	3477	316	150000.00	-800.00	1706.54999999999995	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-04-23 14:32:10.157828	\N	\N	\N	Cutoffs steel plates	\N	t	\N	\N	\N	1	\N	\N	\N	\N	\N	Euro	EP	3	\N	\N	\N
1003	3471	330	2371000.00	102000.00	323.170000000000016	1	\N	\N	\N	\N	\N	\N	true	\N	\N	2021-04-28 07:43:27.850102	\N	\N	\N	Gesamt Fernw├ñrme Plant	\N	t	\N	\N	\N	4	true	\N	\N	\N	\N	CHF	\N	8	\N	\N	\N
1050	3486	350	1.50	2500.00	3.62999999999999989	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-12-01 16:59:53.363437	\N	\N	\N	Waschmittel	\N	t	\N	\N	\N	2	\N	\N	\N	\N	\N	CHF	EP	4	\N	\N	\N
1054	135	354	12.00	123123.00	0.0299999999999999989	2	\N	\N	\N	\N	\N	\N	true	\N	\N	2022-09-07 17:18:47.364186	\N	\N	\N		\N	t	\N	\N	\N	2	true	\N	\N	\N	\N	CHF	\N	3	\N	\N	\N
\.


--
-- Data for Name: t_cmpny_flow_cmpnnt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_flow_cmpnnt (cmpny_flow_id, cmpnnt_id, cmpnt_type_id, qntty, qntty_unit_id, supply_cost, substitute_potential, potential_energy, potential_energy_unit, transport_id, output_cost, output_location, comment, data_quality, entry_date, description, output_cost_unit, supply_cost_unit) FROM stdin;
364	99	1	123.00	4	123.00	qwewqe	\N	\N	\N	123.00	\N	qweqw	123	2018-05-15 16:29:29.495926	test	TL	TL
571	101	1	2000000.00	37	0.00		\N	\N	\N	0.00	\N			2018-07-20 12:24:49.03851		TL	TL
572	100	0	1000000.00	37	144000.00		\N	\N	\N	0.00	\N			2018-07-20 12:21:23.834307	40 kW	TL	CHF
569	103	0	1632.00	45	0.00		\N	\N	\N	0.00	\N			2018-07-20 12:46:24.018896		TL	TL
568	102	0	216000.00	37	17280.00		\N	\N	\N	0.00	\N			2018-07-20 12:45:52.316228		TL	CHF
570	104	0	1632.00	45	0.00		\N	\N	\N	0.00	\N			2018-07-20 12:47:24.516365		TL	TL
\.


--
-- Data for Name: t_cmpny_flow_cmpnnt_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_flow_cmpnnt_location (id, cmpny_flow_cmpnnt_index_test, supply_location, supply_distance) FROM stdin;
\.


--
-- Data for Name: t_cmpny_flow_cmpnnt_waste_threat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_flow_cmpnnt_waste_threat (id, cmpny_id, tec_id, cmpny_flow_cmpnnt_id, output_location, output_distance, transport_id) FROM stdin;
\.


--
-- Data for Name: t_cmpny_flow_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_flow_location (id, cmpny_flow_id, supply_location) FROM stdin;
\.


--
-- Data for Name: t_cmpny_flow_prcss; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_flow_prcss (cmpny_flow_id, cmpny_prcss_id) FROM stdin;
495	113
496	151
227	83
228	84
232	85
231	85
233	86
235	87
234	87
502	152
204	88
250	89
243	89
246	89
250	90
243	90
246	90
246	91
248	92
247	93
248	94
241	94
239	94
237	94
238	94
247	95
241	95
239	95
240	95
237	95
238	95
177	73
181	74
177	74
182	74
181	75
196	76
192	76
197	76
193	76
191	76
198	76
194	76
195	76
196	77
197	77
196	78
192	78
197	78
249	96
204	79
207	80
257	97
256	97
255	97
253	97
252	97
254	97
260	98
503	152
502	153
65	105
276	106
277	107
275	107
278	107
272	107
158	108
204	110
305	113
306	113
303	113
304	113
307	113
308	113
309	113
310	113
314	114
315	114
313	116
318	118
323	119
324	119
314	119
315	119
325	113
325	119
325	122
325	116
325	123
321	113
327	113
328	113
329	113
326	114
328	114
237	124
247	124
239	124
282	98
353	128
355	130
366	131
364	132
367	133
282	134
360	135
380	137
409	138
387	140
386	140
325	141
414	142
415	142
417	142
419	142
418	142
418	143
425	143
415	143
417	143
427	143
428	143
427	142
420	144
415	144
428	144
422	144
420	145
425	145
422	145
430	145
429	145
415	146
431	146
425	147
415	147
432	147
434	148
433	148
421	148
436	150
504	154
504	155
502	155
503	155
303	160
323	160
327	160
303	161
323	161
327	161
328	161
303	162
324	162
328	162
303	122
323	122
303	163
304	163
324	163
323	164
324	164
303	165
324	165
328	165
326	165
303	166
323	166
327	166
519	167
353	168
358	168
353	130
359	171
1017	407
357	128
356	128
307	163
303	176
323	176
303	177
303	178
324	178
327	178
303	179
327	179
328	179
326	179
329	179
495	179
323	165
323	163
327	163
328	163
326	163
303	180
323	180
303	181
323	181
327	181
328	181
303	182
323	182
324	182
303	183
304	183
323	183
324	183
303	184
324	184
327	184
328	184
303	185
323	185
324	185
326	185
1016	442
1021	443
1031	444
1041	446
495	185
325	185
303	186
326	186
329	186
495	186
522	189
527	193
533	195
534	195
303	187
329	187
495	187
325	187
520	188
523	191
526	192
525	192
528	194
530	194
532	194
531	194
565	196
566	197
567	198
567	199
572	200
571	200
568	201
569	202
570	202
508	203
507	203
509	203
365	204
367	204
615	203
622	207
621	208
623	208
626	209
636	209
625	209
634	209
635	209
636	212
626	212
636	213
626	214
652	209
637	209
653	209
652	215
1018	406
577	218
575	219
575	221
576	222
603	223
610	224
1018	442
1017	443
667	227
668	228
672	228
669	229
667	230
684	239
687	239
701	240
699	240
700	240
703	240
704	240
702	240
713	239
706	240
699	241
706	242
701	242
699	243
701	243
712	245
708	245
715	245
714	245
719	245
716	245
717	245
711	245
708	246
719	247
712	247
708	248
712	248
718	249
721	249
723	249
725	249
733	249
726	249
728	249
718	250
733	251
723	251
718	252
723	252
698	253
709	253
710	253
732	253
722	253
724	253
727	253
698	254
730	255
710	255
698	256
710	256
738	257
750	258
748	258
740	258
741	258
747	258
746	258
742	258
744	258
742	259
740	260
747	261
742	262
740	262
739	262
741	262
740	264
742	264
741	264
750	265
748	265
740	265
741	265
747	265
746	265
742	265
744	265
700	243
618	266
757	267
754	267
755	267
756	267
754	268
758	268
758	267
760	270
761	270
765	270
762	270
772	272
765	273
772	270
773	276
772	277
765	277
762	277
780	270
783	279
784	279
787	281
788	281
772	282
792	285
780	282
783	281
791	286
793	286
795	288
797	288
799	288
801	288
802	290
803	292
765	276
772	276
760	276
772	295
822	297
821	297
814	297
816	297
820	297
817	297
822	300
817	300
820	300
826	302
825	302
826	304
825	297
826	297
817	302
825	306
827	306
833	307
855	313
840	314
842	315
848	316
839	317
841	318
860	321
853	321
853	322
865	322
867	322
840	321
845	323
842	325
842	326
844	327
857	328
850	328
845	321
846	330
839	328
844	328
851	320
845	322
851	331
859	331
858	331
846	331
850	332
868	332
866	332
839	332
856	333
857	334
842	333
839	335
843	333
849	333
844	335
877	335
871	335
868	335
866	335
850	335
849	337
843	337
861	337
864	337
878	337
884	335
884	328
860	338
840	338
845	338
865	338
867	338
853	338
885	338
885	322
870	339
886	331
886	320
878	333
888	341
854	342
847	342
855	342
849	343
878	343
842	344
892	345
863	320
656	346
1017	442
1029	442
901	350
1029	444
1045	446
914	356
916	358
917	358
918	338
919	359
840	360
922	361
908	333
922	362
922	363
920	364
841	365
842	366
943	357
945	370
847	372
890	372
891	372
888	372
889	342
888	342
855	373
912	374
914	375
914	376
922	377
914	378
949	380
988	384
978	384
992	386
1009	393
1010	393
1007	393
1006	393
1003	393
1005	393
1004	401
1020	406
1017	406
1019	406
1021	407
\.


--
-- Data for Name: t_cmpny_grp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_grp (id, cmpny_id, group_id) FROM stdin;
\.


--
-- Data for Name: t_cmpny_nace_code; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_nace_code (cmpny_id, nace_code_id) FROM stdin;
3403	500
8	1
3404	57
3406	39
3407	14
3405	121
3408	271
3409	177
3410	58
3412	133
3411	129
3413	64
3414	81
3415	82
3416	63
3417	138
3418	64
3420	32
3421	322
3424	184
3423	123
67	1
3427	18
3429	77
3430	77
3426	64
3432	64
3433	77
3436	77
98	2
99	3
3437	64
3439	511
3440	64
3434	77
3425	77
3442	19
3443	64
139	4
3375	1
66	1
3446	77
3376	1
3378	1
3422	26
3382	1
3356	5
125	323
3357	57
3364	1
3366	1
3365	1
3367	1
3368	1
3369	1
3370	1
138	5
137	6
3372	1
65	1
3373	1
3371	1
3419	64
3447	511
136	3
3374	1
3444	82
3389	1
131	5
3390	2190
134	2535
3388	1
3394	2266
3448	168
135	230
3458	84
3457	84
3459	84
3460	84
3461	84
3456	445
3466	557
3467	145
3455	84
3462	84
3471	76
3472	438
3474	166
3475	302
3476	111
3477	239
3478	275
3479	272
3480	250
3481	199
3483	152
3485	84
3490	442
3489	442
3486	615
3492	84
3493	84
3494	84
3497	90
3498	84
3491	66
3500	84
3495	90
3496	84
\.


--
-- Data for Name: t_cmpny_org_ind_reg; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_org_ind_reg (org_ind_reg_id, cmpny_id) FROM stdin;
\.


--
-- Data for Name: t_cmpny_prcss; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_prcss (id, cmpny_id, prcss_id, prcss_family_id, min_rate_util, min_rate_util_unit, typ_rate_util, typ_rate_util_unit, max_rate_util, max_rate_util_unit, comment) FROM stdin;
131	135	333	\N	500	46	0	1	0	1	
132	135	340	\N	0	1	0	1	0	1	
133	135	341	\N	0	1	0	1	0	1	
80	7	316	\N	100	2	100	2	100	2	comment
88	7	8	\N	0	1	0	1	0	1	test comment
79	7	315	\N	100	2	100	2	100	2	yeni comment
110	7	38	\N	0	1	0	1	0	1	 
107	13	151	\N	1	1	1	1	1	1	 
106	13	136	\N	1	3	1	2	1	2	 
105	13	166	\N	1	1	1	1	1	1	 
98	97	328	\N	60	2	80	2	100	2	 
97	96	327	\N	60	1	70	1	90	1	 
96	94	326	\N	50	1	75	1	100	1	 
95	94	325	\N	80	1	90	1	100	1	 
94	94	324	\N	80	1	90	1	100	1	 
93	94	323	\N	10	1	25	1	30	1	 
92	94	322	\N	25	2	50	2	75	2	 
91	95	321	\N	0	1	0	1	0	1	 
90	95	36	\N	0	1	0	1	0	1	 
89	95	46	\N	0	1	0	1	0	1	 
87	88	320	\N	0	1	0	1	0	1	 
86	88	319	\N	0	1	0	1	0	1	 
134	97	136	\N	80	1	80	1	60	1	ttttttt
85	91	318	\N	0	1	0	1	0	1	 
84	88	66	\N	0	1	0	1	0	1	 
83	88	215	\N	0	1	0	1	0	1	 
137	139	344	\N	0	1	0	1	0	1	
108	10	315	\N	0	1	0	1	0	1	eeeee
138	3359	3	\N	\N	\N	\N	\N	\N	\N	
140	3358	332	\N	\N	\N	\N	\N	\N	\N	sxdgfds
124	94	310	\N	50	2	70	2	20	2	sdfdsf
78	63	20	\N	10	2	10	2	10	2	 
77	63	36	\N	20	2	30	2	40	2	 
76	63	34	\N	0	1	0	1	0	1	 
75	61	314	\N	0	1	0	1	0	1	 
74	61	313	\N	100	32	500	1	2000	1	 
73	61	136	\N	0	1	0	1	0	1	 
118	132	333	\N	0	1	2241	38	0	1	
114	132	331	\N	0	1	2241	38	0	1	
116	132	332	\N	1	32	1121	38	1	32	
141	132	345	\N	\N	\N	\N	\N	\N	\N	
119	132	334	\N	0	1	2241	38	0	1	
142	3362	346	\N	\N	\N	\N	\N	\N	\N	
143	3362	347	\N	\N	\N	\N	\N	\N	\N	
144	3362	348	\N	\N	\N	\N	\N	\N	\N	chiller
145	3362	349	\N	\N	\N	\N	\N	\N	\N	
146	3362	350	\N	\N	\N	\N	\N	\N	\N	
147	3362	351	\N	\N	\N	\N	\N	\N	\N	
148	3362	352	\N	\N	\N	\N	\N	\N	\N	
150	7	100	\N	\N	\N	\N	\N	\N	\N	
151	96	310	\N	\N	\N	\N	\N	\N	\N	sdsdf
152	3383	353	\N	\N	\N	\N	\N	\N	\N	
153	3383	335	\N	\N	\N	\N	\N	\N	\N	
154	3383	38	\N	\N	\N	\N	\N	\N	\N	
155	3383	152	\N	\N	\N	\N	\N	\N	\N	
183	132	39	\N	\N	\N	\N	\N	\N	\N	
184	132	141	\N	\N	\N	\N	\N	\N	\N	
185	132	269	\N	\N	\N	\N	\N	\N	\N	
186	132	249	\N	\N	\N	\N	\N	\N	\N	
187	132	53	\N	\N	\N	\N	\N	\N	\N	
188	3393	354	\N	\N	\N	\N	\N	\N	\N	
122	132	335	\N	0	1	2241	38	0	1	
113	132	2	\N	0	1	2241	38	0	1	
123	132	321	\N	100	38	2241	38	200	38	
160	132	151	\N	\N	\N	\N	\N	\N	\N	
161	132	152	\N	\N	\N	\N	\N	\N	\N	
162	132	66	\N	\N	\N	\N	\N	\N	\N	
163	132	248	\N	\N	\N	\N	\N	\N	\N	ww
164	132	264	\N	\N	\N	\N	\N	\N	\N	
165	132	153	\N	\N	\N	\N	\N	\N	\N	
166	132	233	\N	\N	\N	\N	\N	\N	\N	
167	3391	2	\N	\N	\N	\N	\N	\N	\N	
135	134	342	\N	0	1	0	1	0	1	
130	134	332	\N	0	1	0	1	0	1	
168	134	356	\N	\N	\N	\N	\N	\N	\N	negative
128	134	327	\N	0	1	0	1	0	1	
171	134	357	\N	\N	\N	\N	\N	\N	\N	Lost ressources
313	3457	382	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung aussen
176	132	314	\N	\N	\N	\N	\N	\N	\N	
177	132	149	\N	\N	\N	\N	\N	\N	\N	
178	132	166	\N	\N	\N	\N	\N	\N	\N	
179	132	279	\N	\N	\N	\N	\N	\N	\N	
180	132	215	\N	\N	\N	\N	\N	\N	\N	
181	132	340	\N	\N	\N	\N	\N	\N	\N	
182	132	128	\N	\N	\N	\N	\N	\N	\N	
189	3390	361	\N	\N	\N	\N	\N	\N	\N	Minimum lenght of spacer required to operate production machine
191	3390	362	\N	\N	\N	\N	\N	\N	\N	Safety glass production
192	3390	360	\N	\N	\N	\N	\N	\N	\N	trimming waste
193	3393	20	\N	\N	\N	\N	\N	\N	\N	Processing aluminium by bending it into round shapes
194	3394	363	\N	\N	\N	\N	\N	\N	\N	
195	3394	118	\N	\N	\N	\N	\N	\N	\N	
196	3398	364	\N	\N	\N	\N	\N	\N	\N	
197	3402	151	\N	\N	\N	\N	\N	\N	\N	
198	3401	365	\N	\N	\N	\N	\N	\N	\N	
199	3401	136	\N	\N	\N	\N	\N	\N	\N	test
200	3404	359	\N	\N	\N	\N	\N	\N	\N	
201	3403	332	\N	\N	\N	\N	\N	\N	\N	
202	3403	366	\N	\N	\N	\N	\N	\N	\N	
203	3388	35	\N	\N	\N	\N	\N	\N	\N	
204	135	136	\N	\N	\N	\N	\N	\N	\N	
323	3455	332	\N	\N	\N	\N	\N	\N	\N	
207	3416	367	\N	\N	\N	\N	\N	\N	\N	
208	3416	315	\N	\N	\N	\N	\N	\N	\N	
218	3406	370	\N	\N	\N	\N	\N	\N	\N	
219	3406	321	\N	\N	\N	\N	\N	\N	\N	
443	3474	414	\N	\N	\N	\N	\N	\N	\N	
221	3406	317	\N	\N	\N	\N	\N	\N	\N	
222	3406	353	\N	\N	\N	\N	\N	\N	\N	
223	3412	161	\N	\N	\N	\N	\N	\N	\N	
224	3412	332	\N	\N	\N	\N	\N	\N	\N	
230	3423	332	\N	\N	\N	\N	\N	\N	\N	heating production hall
229	3424	157	\N	\N	\N	\N	\N	\N	\N	
227	3423	321	\N	\N	\N	\N	\N	\N	\N	lighting production hall
228	3423	327	\N	\N	\N	\N	\N	\N	\N	Setup printing machine
240	3439	373	\N	\N	\N	\N	\N	\N	\N	
239	3428	373	\N	\N	\N	\N	\N	\N	\N	
241	3439	370	\N	\N	\N	\N	\N	\N	\N	
242	3439	371	\N	\N	\N	\N	\N	\N	\N	
243	3439	374	\N	\N	\N	\N	\N	\N	\N	
245	3441	373	\N	\N	\N	\N	\N	\N	\N	
246	3441	370	\N	\N	\N	\N	\N	\N	\N	
247	3441	371	\N	\N	\N	\N	\N	\N	\N	
248	3441	374	\N	\N	\N	\N	\N	\N	\N	
213	3419	370	\N	\N	\N	\N	\N	\N	\N	Supplied heat for processes and building
249	3431	373	\N	\N	\N	\N	\N	\N	\N	
250	3431	370	\N	\N	\N	\N	\N	\N	\N	
251	3431	371	\N	\N	\N	\N	\N	\N	\N	
256	3435	374	\N	\N	\N	\N	\N	\N	\N	
314	3455	382	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung aussen
407	3474	406	\N	\N	\N	\N	\N	\N	\N	Reduction of the dust emitted during the process
406	3474	405	\N	\N	\N	\N	\N	\N	\N	Reduction of the  NOx emitted during the process
325	3458	389	\N	\N	\N	\N	\N	\N	\N	G├ñrbottich k├╝hlen
326	3458	50	\N	\N	\N	\N	\N	\N	\N	K├╝hlen des fertigen Bieres
328	3460	379	\N	\N	\N	\N	\N	\N	\N	Brauprozess
330	3456	389	\N	\N	\N	\N	\N	\N	\N	
333	3458	391	\N	\N	\N	\N	\N	\N	\N	
334	3460	392	\N	\N	\N	\N	\N	\N	\N	Gesamte Brauerei
339	3461	389	\N	\N	\N	\N	\N	\N	\N	
341	3457	332	\N	\N	\N	\N	\N	\N	\N	Gas zur W├ñrmeerzeugung
331	3456	315	\N	\N	\N	\N	\N	\N	\N	
344	3458	394	\N	\N	\N	\N	\N	\N	\N	Brauzeit Verk├╝rzen
444	3474	488	\N	\N	\N	\N	\N	\N	\N	
446	3486	415	\N	\N	\N	\N	\N	\N	\N	
360	3455	321	\N	\N	\N	\N	\N	\N	\N	
318	3456	382	\N	\N	\N	\N	\N	\N	\N	K├ñlteanlage
363	3468	359	\N	\N	\N	\N	\N	\N	\N	K├ñlteanlage gesamt
320	3456	379	\N	\N	\N	\N	\N	\N	\N	
366	3458	321	\N	\N	\N	\N	\N	\N	\N	
370	3468	332	\N	\N	\N	\N	\N	\N	\N	W├ñrmeprozesse f├╝r Brauerei
357	3462	332	\N	\N	\N	\N	\N	\N	\N	Genutztes Gas zur W├ñrme Erzeugung
377	3468	7	\N	\N	\N	\N	\N	\N	\N	Umkehrosmose zur Produktion von deionisiertem Wasser
384	3478	329	\N	\N	\N	\N	\N	\N	\N	
401	3472	332	\N	\N	\N	\N	\N	\N	\N	
252	3431	374	\N	\N	\N	\N	\N	\N	\N	
321	3455	379	\N	\N	\N	\N	\N	\N	\N	
315	3458	382	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung aussen
335	3460	391	\N	\N	\N	\N	\N	\N	\N	Gesamte Brauerei
317	3460	382	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung
332	3460	315	\N	\N	\N	\N	\N	\N	\N	CIP Reinigung
342	3457	379	\N	\N	\N	\N	\N	\N	\N	Malz und Hopfen f├╝r den Brauprozess
345	3463	395	\N	\N	\N	\N	\N	\N	\N	
358	3467	391	\N	\N	\N	\N	\N	\N	\N	Bioreaktor Herstellung von Nahrungserg├ñnzungsmittel
361	3468	321	\N	\N	\N	\N	\N	\N	\N	Beleuchtung in der Brauerei
364	3468	379	\N	\N	\N	\N	\N	\N	\N	Brauprozess
372	3457	315	\N	\N	\N	\N	\N	\N	\N	
376	3462	321	\N	\N	\N	\N	\N	\N	\N	Beleuchtung
378	3462	7	\N	\N	\N	\N	\N	\N	\N	Mittels Umkehrosmose entionisiertes Wasser erzeugen
253	3435	373	\N	\N	\N	\N	\N	\N	\N	
254	3435	370	\N	\N	\N	\N	\N	\N	\N	
255	3435	371	\N	\N	\N	\N	\N	\N	\N	
257	3438	375	\N	\N	\N	\N	\N	\N	\N	
258	3443	368	\N	\N	\N	\N	\N	\N	\N	
259	3443	354	\N	\N	\N	\N	\N	\N	\N	
260	3443	370	\N	\N	\N	\N	\N	\N	\N	
261	3443	371	\N	\N	\N	\N	\N	\N	\N	
262	3443	369	\N	\N	\N	\N	\N	\N	\N	
264	3443	377	\N	\N	\N	\N	\N	\N	\N	
265	3443	378	\N	\N	\N	\N	\N	\N	\N	
266	3417	279	\N	\N	\N	\N	\N	\N	\N	
267	3444	379	\N	\N	\N	\N	\N	\N	\N	
268	3444	315	\N	\N	\N	\N	\N	\N	\N	
316	3461	382	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung aussen
322	3455	315	\N	\N	\N	\N	\N	\N	\N	
327	3460	332	\N	\N	\N	\N	\N	\N	\N	Heizenergie
272	3446	354	\N	\N	\N	\N	\N	\N	\N	
337	3458	315	\N	\N	\N	\N	\N	\N	\N	
338	3455	391	\N	\N	\N	\N	\N	\N	\N	
442	3474	412	\N	\N	\N	\N	\N	\N	\N	
343	3458	393	\N	\N	\N	\N	\N	\N	\N	
306	3451	370	\N	\N	\N	\N	\N	\N	\N	
307	3452	372	\N	\N	\N	\N	\N	\N	\N	
346	3422	319	\N	\N	\N	\N	\N	\N	\N	Feeding
350	3465	395	\N	\N	\N	\N	\N	\N	\N	F├╝ttern der Schweine
212	3419	369	\N	\N	\N	\N	\N	\N	\N	Disinfection of storage tanks and production equipment (e.g. pasteurization) with hot water before process start
209	3419	368	\N	\N	\N	\N	\N	\N	\N	Cleaning in place (CIP) of storage tanks and production equipment (e.g. pasteurization) after process end
214	3419	354	\N	\N	\N	\N	\N	\N	\N	Supplied electricity for processes and building
215	3419	371	\N	\N	\N	\N	\N	\N	\N	Pushing milk with water at process start and end. The milk/water phase is dischareged into the waste water
277	3446	367	\N	\N	\N	\N	\N	\N	\N	pasteurising and processing of milk
270	3446	368	\N	\N	\N	\N	\N	\N	\N	
273	3446	370	\N	\N	\N	\N	\N	\N	\N	
359	3466	396	\N	\N	\N	\N	\N	\N	\N	
362	3468	382	\N	\N	\N	\N	\N	\N	\N	
365	3456	321	\N	\N	\N	\N	\N	\N	\N	Beleuchtung mit Leuchtstofflampen
373	3457	321	\N	\N	\N	\N	\N	\N	\N	
282	3446	371	\N	\N	\N	\N	\N	\N	\N	
288	3448	384	\N	\N	\N	\N	\N	\N	\N	This is the clinker production process. In this process 100% petcoke is used.
290	3448	386	\N	\N	\N	\N	\N	\N	\N	SNCR NOx reduction process
292	3448	387	\N	\N	\N	\N	\N	\N	\N	Dust filter technology ESP & fabric filter
276	3446	380	\N	\N	\N	\N	\N	\N	\N	
285	3447	383	\N	\N	\N	\N	\N	\N	\N	
286	3447	382	\N	\N	\N	\N	\N	\N	\N	
279	3447	332	\N	\N	\N	\N	\N	\N	\N	
281	3447	381	\N	\N	\N	\N	\N	\N	\N	
295	3446	388	\N	\N	\N	\N	\N	\N	\N	Energy saved in summer by closing the roller doors
375	3462	359	\N	\N	\N	\N	\N	\N	\N	K├ñlteanlagen
374	3462	379	\N	\N	\N	\N	\N	\N	\N	Brauen
356	3462	382	\N	\N	\N	\N	\N	\N	\N	Energie zum K├╝hlen, verbunden mit Restaurant
380	3463	397	\N	\N	\N	\N	\N	\N	\N	Power production in a nuclar power plant
304	3451	354	\N	\N	\N	\N	\N	\N	\N	
386	3477	329	\N	\N	\N	\N	\N	\N	\N	metal part cleaning
393	3471	402	\N	\N	\N	\N	\N	\N	\N	
297	3451	368	\N	\N	\N	\N	\N	\N	\N	
302	3451	369	\N	\N	\N	\N	\N	\N	\N	
300	3451	371	\N	\N	\N	\N	\N	\N	\N	
\.


--
-- Data for Name: t_cmpny_prcss_eqpmnt_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_prcss_eqpmnt_type (cmpny_eqpmnt_type_id, cmpny_prcss_id) FROM stdin;
\.


--
-- Data for Name: t_cmpny_production_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_production_details (id, cmpny_id, production_type_id, shift_total_week, production_closed) FROM stdin;
\.


--
-- Data for Name: t_cmpny_prsnl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_prsnl (user_id, cmpny_id, is_contact, key_column) FROM stdin;
48228	3403	1	3376
48228	3404	1	3377
48230	3405	1	3378
48230	3406	1	3379
48230	3407	1	3380
48230	3408	1	3381
48230	3409	1	3382
48230	3410	1	3383
48230	3411	1	3384
48230	3412	1	3385
48230	3413	1	3386
48230	3414	1	3387
48230	3415	1	3388
28	3416	1	3389
28	3417	1	3390
28	3418	1	3391
28	3419	1	3392
48230	3420	1	3393
48230	3421	1	3394
32	65	1	20
32	66	1	21
32	67	1	22
28	3422	1	3395
48230	3423	1	3396
48230	3424	1	3397
48232	3423	0	3400
48232	135	0	3401
48232	3416	0	3402
48234	3423	0	3403
48234	3424	0	3404
48235	3425	1	3405
48238	3426	1	3406
48236	3427	1	3407
48238	3429	1	3409
48237	3430	1	3410
48239	3432	1	3412
48237	3433	1	3413
48235	3434	1	3414
48237	3436	1	3416
48238	3436	0	3417
48239	3437	1	3418
48240	3439	1	3420
48241	3440	1	3421
48235	3434	0	3423
48242	3442	1	3424
48242	3443	1	3425
48244	3444	1	3431
48246	3446	1	3435
48249	3447	1	3436
48247	3446	0	3437
48250	3447	0	3438
48245	3448	1	3439
48247	3446	0	3440
28	3448	0	3443
33	98	1	72
33	99	1	73
1	3356	1	3318
1	3357	1	3319
48251	3448	0	3444
28	3447	0	3445
32	3364	1	3326
32	3365	1	3327
32	3366	1	3328
48259	3455	1	3452
48260	3456	1	3453
1	125	1	87
48258	3457	1	3454
32	3367	1	3329
48263	3458	1	3455
48257	3459	1	3456
48262	3460	1	3457
1	131	1	93
48264	3461	1	3458
48261	3462	1	3459
35	134	1	96
36	135	1	97
36	136	1	98
36	137	1	99
36	138	1	100
39	139	1	101
32	3368	1	3330
32	3369	1	3331
32	3370	1	3332
32	3371	1	3333
32	3372	1	3334
32	3373	1	3335
32	3374	1	3336
32	3375	1	3337
32	3376	1	3338
32	3378	1	3340
32	3382	1	3344
48259	3466	0	3470
48259	3466	1	3471
28	3388	1	3350
48207	3389	1	3351
28	3390	1	3352
28	3467	0	3472
48257	3467	0	3473
35	3390	0	3355
48258	3467	0	3474
1	134	0	3357
48261	3467	1	3475
48205	3394	1	3359
48205	3394	0	3360
33	3388	0	3361
33	3390	0	3362
33	134	0	3363
48216	3394	0	3364
28	3471	0	3498
48266	3471	1	3499
28	3472	0	3500
48270	3472	1	3501
48271	3472	0	3502
48267	3471	0	3510
48265	3474	0	3511
28	3474	0	3512
48268	3474	1	3513
48269	3474	0	3515
28	3475	1	3517
28	3476	0	3518
48272	3476	0	3519
48272	3476	1	3520
28	3477	0	3521
48272	3477	0	3522
48272	3477	1	3523
28	3478	0	3524
48272	3478	0	3525
48272	3478	1	3526
28	3479	0	3527
48272	3479	0	3528
48272	3479	1	3529
28	3480	0	3530
48272	3480	0	3531
48272	3480	1	3532
28	3481	0	3533
48272	3481	0	3534
48272	3481	1	3535
28	3483	0	3537
48281	3483	1	3538
48245	3474	0	3541
28	3485	0	3542
48292	3485	1	3543
28	3486	0	3544
48294	3486	0	3545
48293	3486	1	3546
48291	3486	0	3549
48292	3486	0	3551
48295	3486	0	3552
28	3489	0	3553
48294	3489	0	3554
48291	3489	0	3555
48291	3489	1	3556
28	3490	0	3560
48294	3490	0	3561
48291	3490	0	3562
48294	3490	1	3563
48295	3489	0	3564
48295	3491	0	3565
48296	3491	1	3566
28	3491	0	3570
48296	3492	0	3571
48295	3492	1	3572
48297	3493	1	3574
48298	3494	1	3575
28	3495	0	3576
48299	3495	1	3577
28	3496	0	3578
48300	3496	1	3579
48301	3497	1	3581
28	3498	0	3582
48302	3498	1	3583
48291	3495	0	3584
48304	3500	0	3589
48304	3500	1	3590
48300	3500	0	3591
28	3500	0	3592
48297	3500	0	3593
48298	3500	0	3594
48302	3496	0	3595
48291	3500	0	3596
48298	3496	0	3597
48297	3496	0	3598
48299	3496	0	3599
48294	3496	0	3600
28	3492	0	3601
48296	3496	0	3602
48304	3496	0	3603
48304	3492	0	3604
48300	3493	0	3605
48292	3496	0	3607
28	3493	0	3608
48300	3498	0	3609
48298	3493	0	3610
48304	3493	0	3611
48295	3496	0	3612
48292	3493	0	3613
48298	3498	0	3614
48294	3498	0	3616
48297	3498	0	3617
48293	3498	0	3618
48291	3498	0	3619
48303	3498	0	3620
48295	3498	0	3621
48292	3498	0	3622
48304	3498	0	3623
48299	3498	0	3624
48294	3498	0	3625
48296	3498	0	3626
\.


--
-- Data for Name: t_cmpny_prsnl_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_prsnl_details (id, cmpny_id, grad_licence_cnt, grad_highschool_cnt, grad_tecnicalschool_cnt, foreman_cnt, grad_masterdegree_cnt, total_emp) FROM stdin;
\.


--
-- Data for Name: t_cmpny_sector; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cmpny_sector (id, cmpny_id, sector_id) FROM stdin;
\.


--
-- Data for Name: t_cnsltnt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cnsltnt (user_id, description, active) FROM stdin;
1	desc	1
33	gmassard	1
32	emily_vuylsteke	1
35	catherinemoser	1
28	FHNWuser	1
36	ConsultantTest	1
48205	daina	1
48207	monika	1
48216	ingstu	1
48230	aureliesofies	1
48228	alexandre	1
48232	test49	1
48234	nsulzberger	1
48238	angie	1
48239	andyport	1
48235	marger	1
48237	giogio93	1
48236	holiver1991	1
48241	angie213	1
48240	liviaengel	1
48242	ceosparrii	1
48244	johndoe	1
48246	valentina	1
48247	margaret	1
48248	user123	1
48249	dominic	1
48250	anika	1
48245	bgisi	1
48251	yvese	1
48253	xandalf2	1
48256	fhnwtestuser3	1
48259	pnaef	1
48260	stefanlehmann18	1
48257	josip	1
48263	dominicjaggi	1
48262	michaelp	1
48258	saladin	1
48264	claudia	1
48261	joelt	1
48268	fabioribeiro	1
48266	fhnwraphaelmundt	1
48265	jeremy	1
48270	mrose	1
48271	michaelburri	1
48267	jonasj	1
48269	maelcantini	1
48272	mmeister	1
48273	miromeister	1
48279	mturyanytsaukr	1
48277	ivan37	1
48282	nata520522	1
48283	ignsborodina	1
48274	romanpr	1
48275	sfilatov	1
48280	kostyantyn	1
48276	andrii	1
48281	vasyl123	1
48284	elladmytrochenkova	1
48278	plashykhin	1
48285	nadiiashmygol	1
48286	tania	1
48294	emanuel	1
48291	sirheldsamuel	1
48292	planger	1
48293	clement	1
48295	rinarohrbach	1
48296	nikema	1
48297	dominik25	1
48298	moonbaer	1
48302	benjaminbue	1
48299	donsrose	1
48303	samtheman	1
48300	alessia	1
48304	trutelaryjori	1
48301	yanickfrei	1
\.


--
-- Data for Name: t_costbenefit_temp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_costbenefit_temp (cp_id, is_id, capexold, "flow-name-1", "flow-value-1", "flow-unit-1", "flow-specost-1", "flow-opex-1", "flow-eipunit-1", "floweip-1", "annual-cost-1", ltold, investment, disrate, "capex-1", "flow-name-2", "flow-value-2", "flow-unit-2", "flow-specost-2", "flow-opex-2", "flow-eipunit-2", "flow-eip-2", "annual-cost-2", "flow-name-3", "flow-value-3", "flow-unit-3", "flow-opex-3", "ecoben-1", "ecoben-eip-1", "marcos-1", "payback-1", "flow-name-1-2", "flow-value-1-2", "flow-unit-1-2", "flow-specost-1-2", "flow-opex-1-2", "flow-eipunit-1-2", "flow-eip-1-2", "flow-name-2-2", "flow-value-2-2", "flow-unit-2-2", "flow-specost-2-2", "flow-opex-2-2", "flow-eipunit-2-2", "flow-eip-2-2", "flow-name-3-2", "flow-value-3-2", "flow-unit-3-2", "flow-opex-3-2", "ecoben-eip-1-2", "flow-name-1-3", "flow-value-1-3", "flow-unit-1-3", "flow-specost-1-3", "flow-opex-1-3", "flow-eipunit-1-3", "flow-eip-1-3", "flow-name-2-3", "flow-value-2-3", "flow-unit-2-3", "flow-specost-2-3", "flow-opex-2-3", "flow-eipunit-2-3", "flow-eip-2-3", "flow-name-3-3", "flow-value-3-3", "flow-unit-3-3", "flow-opex-3-3", "ecoben-eip-1-3", "flow-name-1-4", "flow-value-1-4", "flow-unit-1-4", "flow-specost-1-4", "flow-opex-1-4", "flow-eipunit-1-4", "flow-eip-1-4", "flow-name-1-5", "flow-value-1-5", "flow-unit-1-5", "flow-specost-1-5", "flow-opex-1-5", "flow-eipunit-1-5", "flow-eip-1-5", "flow-name-2-5", "flow-value-2-5", "flow-unit-2-5", "flow-specost-2-5", "flow-opex-2-5", "flow-eipunit-2-5", "flow-eip-2-5", "flow-name-3-5", "flow-value-3-5", "flow-unit-3-5", "flow-opex-3-5", "ecoben-eip-1-5", "flow-name-1-6", "flow-value-1-6", "flow-unit-1-6", "flow-specost-1-6", "flow-opex-1-6", "flow-eipunit-1-6", "flow-eip-1-6", "flow-name-2-6", "flow-value-2-6", "flow-unit-2-6", "flow-specost-2-6", "flow-opex-2-6", "flow-eipunit-2-6", "flow-eip-2-6", "flow-name-3-6", "flow-value-3-6", "flow-unit-3-6", "flow-opex-3-6", "ecoben-eip-1-6", "maintan-1", "sum-1", "sum-2", "maintan-1-2", "sum-1-1", "sum-2-1", "sum-3-1", "sum-3-2", "flow-name-2-4", "flow-value-2-4", "flow-unit-2-4", "flow-specost-2-4", "flow-opex-2-4", "flow-eipunit-2-4", "flow-eip-2-4", "flow-name-3-4", "flow-value-3-4", "flow-unit-3-4", "flow-opex-3-4", "ecoben-eip-1-4", pkey) FROM stdin;
58	\N	12000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1
\N	66	90000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2
111	\N	1500.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5
109	\N	100.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6
39	\N	95000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7
97	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8
121	\N	0.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9
98	\N	10.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	10
133	\N	0.00	Electrcity	2700	kWh	0.14	378.00000000000006	0.257	693.9	15369	15	100000	5	9634.228760924434	Electricity	2700	kWh	0.14	378.00000000000006	0.257	693.9	13277		0		0	-2092	0	-0.30345227734261676	12.323895616578543	Water	11	m3	4.1	45.099999999999994	0.762	8.382	Watter	0			0		0		11		45	8	Cutting fluid	1200	Liter	8.33	9996	5.119	6142.799999999999	Cutting fluid	392	Liter	8.33	3265.36	5.119	2006.648		808		6731	4136	spent cutting flui	11000	kg	0.45	4950	0.25	2750					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	15369	9593	0	3643	2699	11726	6894	spent cutting flui	0			0		0		11000		4950	2750	11
127	\N	0.10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12
129	\N	0.10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	13
90	\N	0.00					0		0	0				NaN					0		0	NaN		NaN		0	NaN	0	NaN	NaN					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	0	0	0	0	0	0	0					0		0		NaN		0	0	14
128	\N	0.10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	15
126	\N	0.01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	16
138	\N	0.00	Electrcity	2700	kwh	0.14	378.00000000000006	0.257	693.9	15369	15	7000	5	674.3960132647105	Electricity	4900	kwh	0.14	686.0000000000001	0.257	1259.3	12976	Electricty	-2200	kwh	-308	-2393	-566	-1.2079757698132256	3.296380828170851	Water	11	m3	4.1	45.099999999999994	0.762	8.382	Water	11	m3	4.1	45.099999999999994	0.762	8.382	Water	0	m3	0	0	Cutting Fluid	1200	Liter	8.33	9996	5.119	6142.799999999999	Cutting Fluid	1200	Liter	8.33	9996	5.119	6142.799999999999	Cutting Fluid	0	Liter	0	0	Spent Cutting Fluid	11000	Liter	0.45	4950	0.25	2750		0	kwh	0	0	0	0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	15369	9593	0	12302	7612	3067	1981	Spent cutting fluid	3500	Liter	0.45	1575	0.058	203	Spent Cutting Fluid	7500	Liter	3375	2547	17
93	\N	0.00	111				0		0	0				NaN					0		0	NaN		NaN		0	NaN	0	NaN	NaN					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	0	0	0	0	0	0	0					0		0		NaN		0	0	18
113	\N	0.00					0		0	0				NaN					0		0	NaN		NaN		0	NaN	0	NaN	NaN					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	0	0	0	0	0	0	0					0		0		NaN		0	0	19
96	\N	1000000.00					0		0	1000000				NaN					0		0	NaN		NaN		0	NaN	0	NaN	NaN					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	0	0	0	0	0	0	0					0		0		NaN		0	0	23
77	\N	30000.00					0		0	30000				NaN					0		0	NaN		NaN		0	NaN	0	NaN	NaN					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	0	0	0	0	0	0	0					0		0		NaN		0	0	24
156	\N	0.00	cuttingfluid	1200.00	Liter	8.3	9960.00	0.00208	2.4960	14905.00	15	21000	5	2023.19	Cutting fluid	392	Liter	8.33	3265.36	0.00208	0.8154	10188	Cutting fluid	808	Liter	6695	-4717	2	-2358.50	4.50	electrcity	35000	CHF	0.14	4900.00	0.000278	9.7300	electricity	35000	kWh	0.14	4900.00	0.000278	9.7300	electricity	0	kWh	0	0	water	11	m3	4.1	45.10	0.01	0.1100	water	0			0.00		0.0000	water	11	Liter	45	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14905	11	0	8165	9	6740	2					0.00		0.0000		NaN		0	0	27
\N	13	10000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3
110	\N	1.00	Natural_gas	640000.00	kWh	0.11	70400	0.0001875	120	70401				NaN					0		0	NaN		NaN		70400	NaN	120	NaN	NaN	test	1			0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	70400	120	0	0	0	70400	120					0		0		NaN		0	0	21
159	\N	0.00	spend cutting fluid	11000.00	Liter	0.4166666666666667	4583.333333333334	0.0003266666666666667	3.5933333333333333	4583	15	8000	5	770.7383008739548	spend cutting fluid	1600	Liter	0.416	665.6	0.000115	0.184	1743	spend cutting fluid 	9400	Liter	3918	-2840	3	-946.6666666666666	3.1994459833795013	electricty	0	kWh	0.14	0	0.000278	0	electricity	2200	kWh	0.14	308.00000000000006	0.000278	0.6115999999999999	electricity	-2200	kWh	-308	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	4583	3	0	973	0	3610	3					0		0		NaN		0	0	25
168	168	10000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4
139	\N	0.00	Electrcity	885545.00	kWh	0.14	123976.30000000002	0.000278	246.18150999999997	123976	0	0	0	0	Electricity	885545	kWh	0.159	140801.655	0.000100	88.5545	140801	Electricity	0	test	-16825	16825	158	106.4873417721519	0	 				0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0					0		0					0		0					0		0		NaN		0	0					0		0					0		0		NaN		0	0	0	123976	246	0	140801	88	-16825	158					0		0		NaN		0	0	26
182	\N	0.00	Acetone	17432.00	to (tons)	0.28682882055988984	5000.00	2231	38890792.0000	5000.00	20	1000	5	80.24	acetone	10000	tons	0.28682882055988984	2868.29	2231	22310000.0000	2948		7432		2132	-2052	16580792	-0.00	0.75					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	5000	38890792	0	2868	22310000	2132	16580792					0.00		0.0000		NaN		0	0	28
86	\N	0.00	Natural_gas	12000.00	m┬│	1.25	15000.00	2.34	28080.0000	15000.00				0		test1			NaN		NaN	NaN		NaN		NaN	NaN	NaN	NaN	NaN					0.00		0.0000		test1			NaN		NaN		NaN		NaN	NaN					0.00		0.0000		test1			NaN		NaN		NaN		NaN	NaN					0.00		0.0000					0.00		0.0000		test1			NaN		NaN		NaN		NaN	NaN					0.00		0.0000		test1			NaN		NaN		NaN		NaN	NaN	0	15000	28080	0	NaN	NaN	NaN	NaN		test1			NaN		NaN		NaN		NaN	NaN	20
99	\N	12.00	uranium	50002	kwh	0.21	10500.42	2	100004.0000	11742.00	5	50000	11	13528.52	test	test value	asda	1	NaN	21	NaN	NaN	asd	NaN	as	NaN	NaN	NaN	NaN	NaN	asda	123	mw	2	246.00	3	369.0000	test	test value	asd	1	NaN	2	NaN	asd	NaN	as	NaN	NaN	test	123	asd	2	246.00	3	369.0000	test	test value	ads	1	NaN	21	NaN	ad	NaN	sa	NaN	NaN	test	123	asd	2	246.00	4	492.0000	test	123	asd	2	246.00	3	369.0000	test	test value	asd	3	NaN	2	NaN	asd	NaN	as	NaN	NaN	test	123	asd	2	246.00	2	246.0000	test	test value	asd	4	NaN	2	NaN	sad	NaN	as	NaN	NaN	0	11730	101849	0	NaN	NaN	NaN	NaN	test	test value	asd	2	NaN	22	NaN	asdasd	NaN	as	NaN	NaN	22
198	\N	0.00	paper_waste	30000.00	kg	-0.04	-1200.00	3.528	105840.0000	9998800.00	15	500000	3	41883.29	paper_waste	20000	kg	-0.04	-800.00	3.528	70560.0000	10031083	paper _waste	10000	kg	-400	32283	35280	0.92	65.44	paper	10000000	kg	1	10000000.00	0	0.0000	paper	9990000	kg	1	9990000.00	0	0.0000	paper	10000	kg	10000	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	9998800	105840	0	9989200	70560	9600	35280					0.00		0.0000		NaN		0	0	40
263	\N	0.00	test	1000	kWh	5.3	5300.00	450	450000.0000	5300.00	10	20000	12	3539.68	test	1200	kWh	12	14400.00	100000	120000000.0000	17939	test	-200	kWh	-9100	12639	-119550000	-0.00	-3.89					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	5300	450000	0	14400	120000000	-9100	-119550000					0.00		0.0000		NaN		0	0	34
189	\N	0.00	rawmilk	60000.00	kg	0.55	33000.00	3.522	211320.0000	42786.00	0	0	5	0	raw milk	30000	kg	0.55	16500.00	3.522	105660.0000	21680	raw milk	30000	kg	16500	-21106	105660	-0.18	0.00	water	941000	kg	0.0019	1787.90	0.00419	3942.7900	water	471000	kg	0.0019	894.90	0.004193	1974.9030	water	470000	kg	893	1968	electrcity	15000	kWh	0.131	1965.00	0.5098	7647.0000	electrcity	9300	kg	0.131	1218.30	0.5098	4741.1400	electrcity	5700	kWh	747	2906	MSWI heat	8000	kWh	0.0508	406.40	0.1361	1088.8000	Phosphoric acid	938	kg	3	2814.00	5.945	5576.4100	Phosphoric acid	469	kg	3	1407.00	5.945	2788.2050	Phosphoric acid	469	kg	1407	2788	Sodium  hydroxid	938	kg	3	2814.00	1.583	1484.8540	Sodium  hydroxid	469	kg	3	1407.00	1.583	742.4270	Sodium  hydroxid	469	kg	1407	742	0	42786	231057	0	21680	116585	21106	114472	MSWI heat	5000	kWh	0.0508	254.00	0.1361	680.5000	MSWI heat	3000	kWh	152	408	30
193	\N	0.00	district_heat_mswi	150000.00	kWh	0.068	10200.00	0.1360	20400.0000	17427.00	15	50000	5	4817.11	district_heat_mswi	19909	kwh	0.068	1353.81	0.136	2707.6240	10708	district heat	130091	kWh	8847	-6719	17693	-0.05	6.26	water (Input)	2700000.00	kg	0.0019	5130.00	0.04196	113292.0000	water	1350000	kg	0.0019	2565.00	0.00419	5656.5000	water	1350000	kg	2565	107636	electricit	16011	kWh	0.131	2097.44	0.5098	8162.4078	electricity	2700	kWh	0.131	353.70	0.5098	1376.4600	electrcixity	13311	kWh	1744	6786		0		0	0.00	0	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	17427	141854	0	5891	10796	11536	131058	desinf_chemical	405	kg	4	1620.00	2.61	1057.0500	desinf_chemical	-405	kg	-1620	-1057	29
261	\N	1200.00	test	1000	kWh	5.3	5300.00	450	450000.0000	6500.00	10	20000	12	3539.68	test	800	kWh	12	9600.00	100000	80000000.0000	13139	test	200	kWh	-4300	6639	-79550000	-0.00	-8.23					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	5300	450000	0	9600	80000000	-4300	-79550000					0.00		0.0000		NaN		0	0	35
223	\N	1200.00	test	1000	kWh	5.3	5300.00	450	450000.0000	6500.00	10	20000	12	3539.68	test	1000	kWh	12	12000.00	100000	100000000.0000	15539	test	0	kWh	-6700	9039	-99550000	-0.00	-5.28					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	5300	450000	0	12000	100000000	-6700	-99550000					0.00		0.0000		NaN		0	0	36
\N	224	0.00	test	0	kWh	0	0.00	0	0.0000	0.00	1	20000	1	20200.00	test	0	0	0	0.00	0	0.0000	20200	test	0	0	0	20200	0	Infinity	Infinity					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	37
197	\N	0.00	electricity_ch	76700.00	kWh	1.2	92040.00	0.2313124936114733	17741.6683	92040.00	20	100000	3	6721.57	electricity_ch	40000	kWh	0.12	4800.00	0.2313124936114733	9252.4997	11521	electricity_ch	36700	kWh	87240	-80519	8489	-9.49	1.54					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	92040	17741	0	4800	9252	87240	8489					0.00		0.0000		NaN		0	0	33
\N	265	1200.00	heat	50	MJ	5.3	265.00	450	22500.0000	1465.00	10	20000	1	2111.64	heat	45	MJ	4.33	194.85	400	18000.0000	2305	heat	5	MJ	71	840	4500	0.19	297.32					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	265	22500	0	194	18000	71	4500					0.00		0.0000		NaN		0	0	38
\N	267	1.00	heat	1000	MJ	5.3	5300.00	450	450000.0000	5301.00	1	20000	12	22400.00	heat	23	l	4.33	99.59	400	9200.0000	22499	heat	977	MJ	5201	17198	440800	0.04	4.31					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	5300	450000	0	99	9200	5201	440800					0.00		0.0000		NaN		0	0	39
\N	279	0.00	aluminium	20592	kg	1	20592.00	9.040863421	186169.4596	20592.00	0	0	0	0	aluminium	20592	kg	1	20592.00	9.040863421	186169.4596	20592	aluminium	0	kg	0	0	0	NaN	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	20592	186169	0	20592	186169	0	0					0.00		0.0000		NaN		0	0	41
\N	278	0.00	flow1	2	kg	1	2.00	1	2.0000	2.00	0	0	0	0	flow1	1	kg	1	1.00	1	1.0000	1	flow1	1	kg	1	-1	1	-1.00	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2	2	0	1	1	1	1					0.00		0.0000		NaN		0	0	42
\N	158	5.00					0.00		0.0000	5.00				0					0.00		0.0000	0		NaN		0	-5	0	-Infinity	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	45
\N	153	54555.00					0.00		0.0000	54555.00				0					0.00		0.0000	0		NaN		0	-54555	0	-Infinity	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	46
\N	209	88888.00					0.00		0.0000	88888.00				0					0.00		0.0000	0		NaN		0	-88888	0	-Infinity	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	47
\N	160	7777.00					0.00		0.0000	7777.00				0					0.00		0.0000	0		NaN		0	-7777	0	-Infinity	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	48
\N	179	13.00					0.00		0.0000	13.00				0					0.00		0.0000	0		NaN		0	-13	0	-Infinity	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	49
\N	174	66.00					0.00		0.0000	66.00				0					0.00		0.0000	0		NaN		0	-66	0	-Infinity	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	0	0	0	0	0	0					0.00		0.0000		NaN		0	0	50
\N	297	600.00	flow	3	kWh	5.3	15.90	450	1350.0000	615.00				0					0.00		0.0000	0		NaN		15	-615	1350	-0.46	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	15	1350	0	0	0	15	1350					0.00		0.0000		NaN		0	0	43
\N	298	5.00	heat	111	MJ	4.0502	449.57	45	4995.0000	454.00				0					0.00		0.0000	0		NaN		449	-454	4995	-0.09	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	449	4995	0	0	0	449	4995					0.00		0.0000		NaN		0	0	44
\N	308	0.00	rawmilk_losses	300000.00	kg	0.55	165000.00	3.59419	1078257.0000	165000.00	15	300000	5	28902.69	rawmilk_losses	200000	kg	0.40	80000.00	3.59419	718838.0000	110212	rawmilk_loss	100000	kg	85000	-54788	359419	-0.15	5.18					0.00		0.0000	electricity	10000	kWh	0.131	1310.00	0.5098	5098.0000		NaN		-1310	-5098					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	165000	1078257	0	81310	723936	83690	354321					0.00		0.0000		NaN		0	0	52
\N	302	0.00	Al-sheet used	20595.00	kg	-0.88	-18123.60	9.0935	187280.6325	-18123.00	0	0	0	0	Al-sheet used	13995	kg	-8	-111960.00	9.0935	127263.5325	-111960	Al-sheet used	6600	kg	93837	-93837	60017	-1.56	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	-18123	187280	0	-111960	127263	93837	60017					0.00		0.0000		NaN		0	0	51
196	\N	0.00	rawmilk_losses	300000.00	kg	0.55	165000.00	3.59419	1078257.0000	165000.00	15	1400000	5	134879.20	rawmilk	200000	kg	0.0	0.00	3.59419	718838.0000	174179	rawmilk	100000	kg	165000	9179	359419	0.04	16.10					0.00		0.0000	electricity	300000	kWh	0.131	39300.00	0.5098	152940.0000		NaN		-39300	-152940					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	165000	1078257	0	39300	871778	125700	206479					0.00		0.0000		NaN		0	0	32
241	\N	12000.00	Heat	4000.00	MJ	0.5	2000.00	18.05	72200.0000	14012.00	10000	1200	3	36.00	heat	3000	MJ	0.3	900.00	15	45000.0000	948	heat	1000	MJ	1100	-13064	27200	-0.48	327.27	Water (Input)	6000.00	kg	0.002	12.00	0.46	2760.0000	Water (Input)	6000.00	kg	0.002	12.00	0.46	2760.0000	Water (Input)	0	kg	0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2012	74960	0	912	47760	1100	27200					0.00		0.0000		NaN		0	0	55
\N	309	0.00	rawmilk_losses	300000.00	kg	0.55	165000.00	3594.19	1078257000.0000	165000.00	0	0	0	0	rawmilk_losses	200000.00	kg	1	200000.00	3594.19	718838000.0000	200000	rawmilk_losses	100000	kg	-35000	35000	359419000	0.00	0.00			kg		0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	165000	1078257000	0	200000	718838000	-35000	359419000					0.00		0.0000		NaN		0	0	53
202	\N	12.00	heat_mswi	327.72	MWh	311.2413035518125	102000.00	0.1360917856706945	44.6000	102012.00	10	20000	1	2111.64	test	1000	kWh	12	12000.00		0.0000	14111		-673		90000	-87901	44	-1997.75	0.23					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	102000	44	0	12000	0	90000	44					0.00		0.0000		NaN		0	0	54
240	\N	12000.00	Water	6000.00	kg	0.0033333333333333335	20.00	0.46	2760.0000	12020.00	10	10000	3	1172.31	Water recycled	3000	kg	0.004	12.00	0.3	900.0000	1184	Water recycled	3000		8	-10836	1860	-5.83	1465.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	20	2760	0	12	900	8	1860					0.00		0.0000		NaN		0	0	56
\N	316	0.00	rawmilk_losses	300000.00	kg	0.55	165000.00	3.59419	1078257.0000	165000.00	15	50000	5	4817.11	rawmilk_losses	100000	kg	-0.1	-10000.00	3.59419	359419.0000	-5183	rawmilk_losses	200000	kg	175000	-170183	718838	-0.24	0.41					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	165000	1078257	0	-10000	359419	175000	718838					0.00		0.0000		NaN		0	0	57
301	\N	0.00	refrigerant_r407c	13.00	kg	67.46153846153847	877.00	945.530146923077	12291.8919	877.00	10	900	2	100.19	repair	0	kg		0.00		0.0000	100		13		877	-777	12291	-0.06	1.14					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	877	12291	0	0	0	877	12291					0.00		0.0000		NaN		0	0	60
416	\N	0.00	Tap water	509980.00	kg	0.001918321	978.31	0.0000011765167261461233	0.6000	1972.77	5	50	3	10.92	Tap water	318737.5	kg	0.001918321	611.44	0.0000011765167261461233	0.3750	1243.8200000000002		191242.5		366.8699999999999	-728.9499999999998	0.22499999999999998	-810.03	0.07	Wasterwater treatment CH (Output)	509.98	m┬│	1.95	994.46	0.0035282837967401726	1.7994	Wasterwater treatment CH (Output)	318.7	m┬│	1.95	621.46	0.0035282837967401726	1.1245	Wasterwater treatment CH (Output)	191.28000000000003	m┬│	373	0.6749					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1972.77	2.3994	0	1232.90	1.4995	739.87	0.8999					0.00		0.0000		NaN		0	0	98
294	\N	2140.00	oil	582000.00	MJ	0.025362542955326462	14761.00	0.06769759450171821	39400.0000	16901.00	25	30000	2	1536.61	district heat	494000.00	MJ	0.02775506072874494	13711.00	0.004149797570850202	2050.0000	15247		88000		1050	-1654	37350	-0.04	36.57					0.00		0.0000					0.00		0.0000		NaN	MJ	0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14761	39400	0	13711	2050	1050	37350					0.00		0.0000		NaN		0	0	59
444	\N	0.00	Electricity CH medium Voltage	59018.54	kWh	0.2613924370206379	15427.00	0.00019654840665323133	11.6000	15427.00	30	1500	3	76.53	Electricity CH medium Voltage	49720	kWh	0.2613924370206379	12996.43	0.00019654840665323133	9.7724	13072.960000000001		9298.54		2430.5699999999997	-2354.039999999999	1.8276000000000003	-1288.05	0.94					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	15427.00	11.6000	0	12996.43	9.7724	2430.57	1.8276					0.00		0.0000		NaN		0	0	118
405	\N	0.00	Electricity CH medium Voltage	31702	kWh	0.256160548830	8120.80	0.0002333284882608995	7.3970	8120.80	20	0	3	0.00	Electricity CH medium Voltage	26418	kWh	0.256160548830	6767.25	0.0002333284882608995	6.1641	6767.25		5284		1353.5500000000002	-1353.5500000000002	1.2328999999999999	-1097.86	0.00	Electricity CH medium Voltage (Input)				0.00		0.0000					0.00		0.0000		NaN	kWh	0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	8120.80	7.3970	0	6767.25	6.1641	1353.55	1.2329					0.00		0.0000		NaN		0	0	95
441	\N	0.00	Electricity CH medium Voltage	4092.58	kWh	0.8356586798547616	3420.00	0.00023457085750309097	0.9600	3420.00	13	3218	3	302.59	Electricity CH medium Voltage	998.4	kWh	0.8356586798547616	834.32	0.00023457085750309097	0.2342	1136.91		3094.18		2585.68	-2283.09	0.7258	-3145.62	1.52					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3420.00	0.9600	0	834.32	0.2342	2585.68	0.7258					0.00		0.0000		NaN		0	0	114
399	\N	0.00	Electricity CH medium Voltage	49700.00	kWh	0.2614486921529175	12994.00	0.00023340040241448691	11.6000	12994.00	15	1000	3	83.77	Electricity CH medium Voltage	45000	kWh	0.2614486921529175	11765.19	0.00023340040241448691	10.5030	11848.960000000001	Electricity	4700	kWh	1228.8099999999995	-1145.039999999999	1.0969999999999995	-1043.79	1.02	Electricity CH medium Voltage (Input)				0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	11.6000	0	11765.19	10.5030	1228.81	1.0970					0.00		0.0000		NaN		0	0	92
\N	336	0.00	Barley Grain	19000	kg	0.0262	497.80	0.00347	65.9300	497.80	5	100	3	21.84	Barley Grain	15000	kg	0	0.00	0.0030	45.0000	21.84		4000		497.8	-475.96000000000004	20.930000000000007	-22.74	0.22					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	497.80	65.9300	0	0.00	45.0000	497.80	20.9300					0.00		0.0000		NaN		0	0	108
438	\N	0.00	Electricity CH medium Voltage	32525.89	kWh	0.3994971390483089	12994.00	0.00023335256929172423	7.5900	12994.00	20	11210.00	3	753.49	Electricity CH medium Voltage	10000	kWh	0.3994971390483089	3994.97	0.00023335256929172423	2.3335	4748.46		22525.89		8999.03	-8245.54	5.2565	-1568.64	1.67					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	7.5900	0	3994.97	2.3335	8999.03	5.2565					0.00		0.0000		NaN		0	0	110
407	\N	0.00	Electricity CH medium Voltage	9408	kWh	0.245156	2306.43	0.0002333284882608995	2.1952	2306.43	20	11210	3	753.49	Electricity CH medium Voltage	4800	kWh	0.3823291773596631	1835.18	0.0002333284882608995	1.1200	2588.67		4608		471.2499999999998	282.24000000000024	1.0751999999999997	262.50	31.98					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2306.43	2.1952	0	1835.18	1.1200	471.25	1.0752					0.00		0.0000		NaN		0	0	101
448	\N	0.00	Electricity CH medium Voltage	50727.00	kWh	0.25615549904390167	12994.00	0.00021251010310091272	10.7800	12994.00	30	32350	3	1650.47	Electricity CH medium Voltage	39225.00	kWh	0.25615549904390167	10047.70	0.00021251010310091272	8.3357	11698.17		11502		2946.2999999999993	-1295.83	2.4443	-530.14	16.81					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	10.7800	0	10047.70	8.3357	2946.30	2.4443					0.00		0.0000		NaN		0	0	122
439	\N	0.00	Electricity CH medium Voltage	4492.80	kWh	0.25615549904390167	1150.86	0.00023370726495726497	1.0500	1150.86	13	3218	3	302.59	Electricity CH medium Voltage	1331.00	kWh	0.25615549904390167	340.94	0.00023370726495726497	0.3111	643.53		3161.8		809.9199999999998	-507.3299999999999	0.7389000000000001	-686.60	4.86					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1150.86	1.0500	0	340.94	0.3111	809.92	0.7389					0.00		0.0000		NaN		0	0	112
310	\N	0.00	refrigerant_r407c	13.00	kg	67.46153846153847	877.00	131.03	1703.3900	877.00	10	900	2	100.19	refrigerant_r407c	0.2	kg	67.46153846153847	13.49	131.03	26.2060	113	refrigerant_r407c	13	kg	864	-764	1677	-0.06	1.16	release	13.00	kg	0	0.00	814.5	10588.5000	release	0.2	kg	0	0.00	814.5	162.9000	release	13	kg	0	10426					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	877	12291	0	13	188	864	12103					0.00		0.0000		NaN		0	0	64
312	\N	0.00	plastic_waste	697.4933333	kg	1.036373281337367	722.86	1.2007914091958307	837.5440	722.00	0	0	0	0	plastic_waste	0	kg	1.036373281337367	0.00	1.2007914091958307	0.0000	636	plastic_waste	697	kg	722	-86	837	-0.25	0.00	petcoke_fuel	593.3898507	kg	0	0.00	1.970617386	1169.3444	petcoke_fuel	0	kg	0	0.00	1.970617386	0.0000	petcoke_fuel	593	kg	0	1169	substitution_energy	0	MJ	0	0.00	0.041346067	0.0000	substitution_energy	8083.947733	MJ	0	0.00	0.041346067	334.2394	substitution_energy	-8083	MJ	0	-334	plastic_fuel	0	kg	0.912909091	0.00	1.904118106	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	722	2006	0	636	1662	86	344	plastic_fuel	697.4933333	kg	0.912909091	636.75	1.904118106	1328.1097	plastic_fuel	-697	kg	-636	-1328	65
303	\N	0.00	Electricity	90100.00	kWh	0.131	11803.10	509.8	45932980.0000	11803.00				0	Electricity	90100.00	kWh	0.131	11803.10	509.8	45932980.0000	11803		0		0	0	0	NaN	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	11803	45932980	0	11803	45932980	0	0					0.00		0.0000		NaN		0	0	61
305	\N	2140.00	oil	582000.00	MJ	0.025362542955326462	14761.00	0.06769759450171821	39400.0000	16901.00	25	30000	2	1536.61	oil	0	MJ	0.025362542955326462	0.00	0.06769759450171821	0.0000	15247	oil	582000	MJ	14761	-1654	39400	-0.04	36.57	district heat	0	MJ	0.02775506072874494	0.00	0.004149797570850202	0.0000	district heat (Input)	494000.00	MJ	0.02775506072874494	13711.00	0.004149797570850202	2050.0000	district heat (Input)	-494000	MJ	-13711	-2050					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14761	39400	0	13711	2050	1050	37350					0.00		0.0000		NaN		0	0	62
\N	377	0.00	Nutritive Biomass	19000	kg	0.0526315	1000.00	3.4736842105	66000.0000	1000.00	10	5000	2.5	571.29	Nutritive Biomass	19000	kg	-0.10	-1900.00	3.4736842105	66000.0000	-1328.71		0		2900	-2328.71	0	-Infinity	1.97					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1000.00	66000.0000	0	-1900.00	66000.0000	2900.00	0.0000					0.00		0.0000		NaN		0	0	133
306	\N	0.00	fresh_water	2273.60	m┬│	2.0689655172413794	4704.00	0.45918367346938777	1044.0000	16063.00	5	2765	2	586.62	fresh_water	1137	m┬│	2.0689655172413794	2352.41	0.45918367346938777	522.0918	8652	fresh water	1136	m┬│	2352	-7411	522	-0.50	0.37	waste_water_general (Output)	2273.60	m┬│	1.6203377902885292	3684.00	3.6910626319493316	8392.0000	waste_water_general (Output)	1137	m┬│	1.6203377902885292	1842.32	3.6910626319493316	4196.7382	waste_water_general (Output)	1136	m┬│	1842	4196	oil (Input)	302640.00	MJ	0.025362542955326462	7675.72	0.06769759450171821	20488.0000	oil (Input)	152685	MJ	0.025362542955326462	3872.48	0.06769759450171821	10336.4072	oil (Input)	149955	MJ	3803	10152					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	16063	29924	0	8066	15054	7997	14870					0.00		0.0000		NaN		0	0	63
281	\N	0.00	district_heat	307749.00	kWh	0.33143893237670957	102000.00	0.1361030072559131	41885.5644	168612.00				0	district_heat	293000.00	kWh	0.331438932	97111.61	0.1361030072559	39878.1811	150023		14749		4889	-18589	2007	-0.00	NaN	Electricity (Input)	265501.00	kWh	0.13093284017762646	34762.80	509.67250247645023	135318559.0800	Electricity (Input)	265501.00	kWh	0.13093284017762646	34762.80	509.67250247645023	135318559.0800	Electricity (Input)	0	kWh	0	0	rawmilk_losses (Output)	57906.30	kg	0.5500265083419248	31850.00	3521.9999999999995	203945988.6000	rawmilk_losses (Output)	33000	kg	0.5500265083419248	18150.87	3521.9999999999995	116226000.0000	rawmilk_losses (Output)	24906	kg	13700	87719988					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	168612	339306432	0	150023	251584437	18589	87721995					0.00		0.0000		NaN		0	0	58
424	\N	0.00	Tap water	120000.00	kg	0.05423516666666667	6508.22	0.0000049999999999999996	0.6000	6607.78	5	40	3	8.73	Tap water	60000.00	kg	0.05423516666666667	3254.11	0.0000049999999999999996	0.3000	3312.62		60000		3254.11	-3295.16	0.3	-2828.46	0.01	Wasterwater treatment CH (Output)	120.00	m┬│	0.8296666666666667	99.56	0.014416666666666666	1.7300	Wasterwater treatment CH (Output)	60.00	m┬│	0.8296666666666667	49.78	0.014416666666666666	0.8650	Wasterwater treatment CH (Output)	60	m┬│	49.78	0.865					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	6607.78	2.3300	0	3303.89	1.1650	3303.89	1.1650					0.00		0.0000		NaN		0	0	100
403	\N	0.00	Electricity CH medium Voltage	11920	kWh	0.256160548830	3053.43	0.00023308617694603763	2.7784	3053.43	20	1500	3	100.82	Electricity CH medium Voltage	4966	kWh	0.2561605488309743	1272.09	0.00023308617694603763	1.1575	1372.9099999999999		6954		1781.34	-1680.52	1.6209	-1036.78	1.13	Electricity CH medium Voltage (Input)				0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3053.43	2.7784	0	1272.09	1.1575	1781.34	1.6209					0.00		0.0000		NaN		0	0	96
\N	351	0.00	nutritive biomass	10000	kg	0.1	1000.00	0.01	100.0000	1000.00	1	0	0.1	0.00	nutritive biomass	0	kg	0	0.00	0	0.0000	0	nutritivebiomass	10000	kg	1000	-1000	100	-10.00	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1000.00	100.0000	0	0.00	0.0000	1000.00	100.0000					0.00		0.0000		NaN		0	0	111
426	\N	0.00	Barley grain	37680.00	kg	0.18577494692144372	7000.00	0.003464171974522293	130.5300	7000.00	100	5000	3	158.23	Barley grain	34680.00	kg	0.18577494692144372	6442.68	0.003464171974522293	120.1375	6600.91		3000		557.3199999999997	-399.09000000000015	10.392499999999998	-38.40	28.39					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	7000.00	130.5300	0	6442.68	120.1375	557.32	10.3925					0.00		0.0000		NaN		0	0	102
\N	368	0.00	nutritive  biomass	38050	kg	0.1	3805.00	0.000004	0.1522	3805.00	5	40	0.1	8.02	nutritive biomass	38050	kg	-0.05	-1902.50	0	0.0000	-1894.48		0		5707.5	-5699.48	0.1522	-37447.31	0.01					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3805.00	0.1522	0	-1902.50	0.0000	5707.50	0.1522					0.00		0.0000		NaN		0	0	116
322	\N	0.00	petcoke	70522388.00	kg	0.11000000453756614	7757463.00	0.021	1480970.1480	7757463.00	10	14000000	3	1641227.09	reduced petcoke	70499821	kg	0.11000000453756614	7754980.63	0.021	1480496.2410	8600418		22567		2483	842955	474	0.01	20.56	co2 (Output)	240224.00	t	0	0.00	1173.575	281920880.8000	co2 (Output)	 166514.00	t	0	0.00	1173.575	195416667.5500	co2 (Output)	73710	t	0	86504213				0	0.00		0.0000				0	0.00		0.0000		NaN		0	0				0	0.00		0.0000	plastic waste (Input)	0	kg	0	0.00	0.985	0.0000	plastic waste (Input)	26526316.00	kg	-0.02999998190476205	-795789.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	795789	-26128421					0.00		0.0000					0.00		0.0000		NaN		0	0	0	7757463	283401850	0	6959191	223025584	798272	60376266				0	0.00		0.0000		NaN		0	0	67
333	\N	0.00	Electricity	0	kWh	0.1	0.00	0.233	0.0000	30098924.00	10	6000000	7.5	874115.56	Electricity	6338250.00	kWh	0.1	633825.00	0.233	1476812.2500	26398790		-6338250		-633825	-3700134	-1476812	-0.45	1.91	petcoke (Input)	70522000.00	kg	0.110	7757420.00	0.021	1480962.0000	petcoke (Input)	 47955000	kg	0.110	5275050.00	0.021	1007055.0000	petcoke (Input)	22567000	kg	2482370	473907	co2 (Output)	594599.00	t	37.57406924666876	22341504.00	460	273515540.0000	co2 (Output)	  518527	t	37.57406924666876	19483169.40	460	238522420.0000	co2 (Output)	76072	t	2858335	34993120	Dust (Output)	7101.00	kg	0	0.00	119	845019.0000	plastic waste (Input)	0	kg	0.0049999781349208084	0.00	0.985	0.0000	plastic waste (Input)	26526316.00	kg	0.0049999781349208084	132631.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	-132631	-26128421					0.00		0.0000					0.00		0.0000		NaN		0	0	0	30098924	275841521	0	25524675	267631890	4574249	8209631	Dust (Output)	 4178	kg	0	0.00	119	497182.0000	Dust (Output)	2923	kg	0	347837	74
434	\N	0.00	Electricity CH medium Voltage	50726.59	kWh	0.2561575694325205	12994.00	0.00023340815931053124	11.8400	12994.00	30	32350	3	1650.47	Electricity CH medium Voltage	39224.59	kWh	0.2561575694325205	10047.68	0.00023340815931053124	9.1553	11698.15		11502		2946.3199999999997	-1295.8500000000004	2.6846999999999994	-482.68	16.81					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	11.8400	0	10047.68	9.1553	2946.32	2.6847					0.00		0.0000		NaN		0	0	107
346	\N	0.00	ammonia	0	kg	0.1	0.00	2.060	0.0000	0.00	10	6000000	7.5	874115.56	ammonia	4860000.00	kg	0.1	486000.00	2.060	10011600.0000	1360115		-4860000		-486000	1360115	-10011600	0.05	-17.99	nitrogen_oxides (Output)	1501875.00	kg	0	0.00	41.864	62874495.0000	nitrogen_oxides (Output)	 600750 	kg	0	0.00	41.864	25149798.0000	nitrogen_oxides (Output)	901125	kg	0	37724697					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	62874495	0	486000	35161398	-486000	27713097					0.00		0.0000		NaN		0	0	83
314	\N	0.00	rawmilk_losses	57906.30	kg	0.5500265083419248	31850.00	3.521	203888.0823	42455.00				0	rawmilk_losses	33000	kg	0.55	18150.00	3.522	116226.0000	23765	rawmilk_losses	24906	kg	13700	-18690	87662	-0.19	NaN	water	940500	kg	0.0019	1786.95	0.003753	3529.6965	water	470250	kg	0.0019	893.48	0.003753	1764.8483	water	470250	kg	893	1765	caustic soda	940.5	kg	3.5	3291.75	1.583	1488.8115	caustic soda	470.25	kg	3.5	1645.88	1.583	744.4058	caustic soda	470	kg	1646	744	phosphoric acid	940.5	kg	3.5	3291.75	5.945	5591.2725	steam	7729	kWh	0.043	332.35	0.1361	1051.9169	steam	5199	kWh	0.043	223.56	0.1361	707.5839	steam	2530	kWh	109	344	electricity	14548	kWh	0.131	1905.79	0.5098	7416.5704	electricity	9235	kWh	0.131	1209.79	0.5098	4708.0030	electricity	5313	kWh	696	2708	0	42455	222963	0	23765	126944	18690	96019	phosphoric acid	470.25	kg	3.5	1645.88	5.945	2795.6363	phosphoric acid	470	kg	1646	2796	66
437	\N	0.00	Electricity CH medium Voltage	30339.57	kWh	0.4282855689780706	12994.00	0.00023335861384983373	7.0800	12994.00	20		3	0.00	Electricity CH medium Voltage	26418.0	kWh	0.4282855689780706	11314.45	0.00023335861384983373	6.1649	11314.45		3921.5699999999997		1679.5499999999993	-1679.5499999999993	0.9150999999999998	-1835.37	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	7.0800	0	11314.45	6.1649	1679.55	0.9151					0.00		0.0000		NaN		0	0	109
431	\N	0.00	Electricity CH medium Voltage	9118.00	kWh	1.4250932221978505	12994.00	0.00023360386049572272	2.1300	12994.00	10	50	3	5.86	Electricity CH medium Voltage	9000.00	kWh	1.4250932221978505	12825.84	0.00023360386049572272	2.1024	12831.7		118		168.15999999999985	-162.29999999999927	0.02760000000000007	-5880.43	0.35					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	2.1300	0	12825.84	2.1024	168.16	0.0276					0.00		0.0000		NaN		0	0	105
410	\N	0.00	Tap water	509980	kg	0.002	1019.96	0.00000046	0.2346	1019.96	20	100	3	6.72	Tap water	127495	kg	0.002	254.99	0.00000046	0.0586	261.71000000000004		382485		764.97	-758.25	0.176	-4308.24	0.18					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1019.96	0.2346	0	254.99	0.0586	764.97	0.1760					0.00		0.0000		NaN		0	0	97
\N	369	0.00	nutritive biomass	20000	kg	0.1	2000.00	0.000004	0.0800	2000.00	5	40	0.1	8.02	nutritive biomass	38050	kg	-0.05	-1902.50	0	0.0000	-1894.48		-18050		3902.5	-3894.48	0.08	-48681.00	0.01					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2000.00	0.0800	0	-1902.50	0.0000	3902.50	0.0800					0.00		0.0000		NaN		0	0	117
445	\N	0.00	Electricity CH medium Voltage	9408	kWh	0.256155	2409.91	0.0002125	1.9992	2409.91	20	11210	3	753.49	Electricity CH medium Voltage	4800	kWh	1.1601785714285715	5568.86	0.0002125	1.0200	6322.349999999999		4608		-3158.95	3912.4399999999996	0.9792000000000001	3995.55	-4.77					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2409.91	1.9992	0	5568.86	1.0200	-3158.95	0.9792					0.00		0.0000		NaN		0	0	119
446	\N	0.00	Electricity CH medium Voltage	49205.19	kWh	0.264077834065878	12994.00	0.0002125792015029309	10.4600	12994.00	20	1500	3	100.82	Electricity CH medium Voltage	40810	kWh	0.264077834065878	10777.02	0.0002125792015029309	8.6754	10877.84		8395.190000000002		2216.9799999999996	-2116.16	1.784600000000001	-1185.79	0.91					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	10.4600	0	10777.02	8.6754	2216.98	1.7846					0.00		0.0000		NaN		0	0	120
\N	323	0.00	plastic_waste	697.4933333	kg	1.036373281337367	722.86	1.2007914091958307	837.5440	722.00	0	0	0	0	plastic_waste	0	kg	1.036373281337367	0.00	1.2007914091958307	0.0000	636	plastic_waste	697	kg	722	-86	837	-0.25	0.00	petcoke_fuel	593.3898507	kg	0	0.00	1.970617386	1169.3444	petcoke_fuel	0	kg	0	0.00	1.970617386	0.0000	petcoke_fuel	593	kg	0	1169	substitution_energy	0	MJ	0	0.00	0	0.0000	substitution_energy	8083.947733	MJ	0	0.00	0.041346067	334.2394	substitution_energy	-8083	MJ	0	-334	plastic_fuel	0	kg	0	0.00	0	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	722	2006	0	636	1662	86	344	plastic_fuel	697.4933333	kg	0.912909091	636.75	1.904118106	1328.1097	plastic_fuel	-697	kg	-636	-1328	72
324	\N	0.00	Electricity	0	kWh	0	0.00	0.233	0.0000	6961674.00	10	6000000	3	703383.04	Electricity	6338250.00	kWh	0	0.00	0.233	1476812.2500	7662574		-6338250		0	700900	-1476812	0.01	2832.80	co2 (Output)	240224.00	t	0	0.00	1173.575	281920880.8000	co2 (Output)	 166514.00	t	0	0.00	1173.575	195416667.5500	co2 (Output)	73710	t	0	86504213	plastic waste (Input)	26526316.00	kg	-0.02999998190476205	-795789.00	0.985	26128421.2600	plastic waste (Input)	26526316.00	kg	-0.02999998190476205	-795789.00	0.985	26128421.2600	plastic waste (Input)	0	kg	0	0	petcoke (Input)	70522388.00	kg	0.11000000453756614	7757463.00	0.021	1480970.1480	Dust (Output)	7101.00	kg	0	0.00	1598.022	11347554.2220	Dust (Output)	4177.575	kg	0	0.00	1598.022	6675856.7566	Dust (Output)	2924	kg	0	4671698					0.00		0.0000					0.00		0.0000		NaN		0	0	0	6961674	320877825	0	6959191	231178252	2483	89699573	petcoke (Input)	70499821	kg	0.11000000453756614	7754980.63	0.021	1480496.2410	petcoke (Input)	22567	kg	2483	474	69
319	\N	0.00	nitrogen_oxides	1501875.00	kg	0	0.00	41.864	62874495.0000	7757463.00	10	8000000	3	937844.05	reduced NOx	600750	kg	0	0.00	46.864	28153548.0000	7897035		901125		0	139572	34720947	0.00	11.75	co2 (Output)	240224.00	t	0	0.00	1173.575	281920880.8000	co2 (Output)	166514.00	t	0	0.00	1173.575	195416667.5500	co2 (Output)	73710	t	0	86504213				0	0.00		0.0000				0	0.00		0.0000		NaN		0	0	plastic waste (Input)	0	kg	0	0.00	0.985	0.0000	petcoke (Input)	70522388.00	kg	0.11000000453756614	7757463.00	0.021	1480970.1480	petcoke reduced (Input)	70499821	kg	0.11000000453756614	7754980.63	0.021	1480496.2410	petcoke (Input)	22567	kg	2483	474	ammonia (Input)	0	kg	0	0.00	2060	0.0000	ammonia (Input)	1269000.00	kg	0	0.00	2.060	2614140.0000	ammonia (Input)	-1269000	kg	0	-2614140	0	7757463	346276345	0	6959191	253793272	798272	92483073	plastic waste (Input)	26526316.00	kg	-0.02999998190476205	-795789.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	795789	-26128421	68
325	\N	0.00	raw_milk	840.00	kg	0.11904761904761905	100.00	3.522	2958.4800	100.00				0	raw_milk				0.00		0.0000	0		NaN		100	-100	2958	-0.03	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	100	2958	0	0	0	100	2958					0.00		0.0000		NaN		0	0	70
331	\N	0.00	petcoke	70522000.00	kg	0.1100006097388049	7757463.00	0.021	1480962.0000	30098967.00	20	15000000	7.5	1471382.87	petcoke reduced by 67%	 47955000 	kg	0.110	5275050.00	0.021	1007055.0000	26332173	petcoke reduced by 67%	22567000	kg	2482413	-3766794	473907	-0.39	5.62	co2 (Output)	594599.00	t	37.57406924666876	22341504.00	460	273515540.0000	co2 (Output)	 517727	t	37.57406924666876	19453110.15	460	238154420.0000	co2 (Output)	76872	t	2888394	35361120	plastic waste (Input)	0	kg	0.0049999781349208084	0.00	0.985	0.0000	plastic waste (Input)	26526316.00	kg	0.0049999781349208084	132631.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	-132631	-26128421					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	30098967	274996502	0	24860791	265289896	5238176	9706606					0.00		0.0000		NaN		0	0	73
401	\N	0.00	Electricity CH medium Voltage	51411.79	kWh	0.2527435827462922	12994.00	0.00023302048032173165	11.9800	12994.00	15	1000	3	83.77	Electricity CH medium Voltage	45000	kWh	0.2527435827462922	11373.46	0.00023302048032173165	10.4859	11457.23		6411.790000000001		1620.5400000000009	-1536.7700000000004	1.4940999999999995	-1028.56	0.78					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	11.9800	0	11373.46	10.4859	1620.54	1.4941					0.00		0.0000		NaN		0	0	103
326	\N	0.00	district_heat	150321.40	kWh	0.043	6463.82	0.1361	20458.7425	13690.00	10	50000	10	8137.27	district_heat	0	kWh	0.043	0.00	0.1361	0.0000	11295	district_heat	150321	kWh	6463	-2395	20458	-0.08	7.73	electricity	16011	kWh	0.131	2097.44	0.5098	8162.4078	electricity	3296	kWh	0.131	431.78	0.5098	1680.3008	electricity	12715	kWh	1666	6482	water	2700000	kg	0.0019	5130.00	0.003753	10133.1000	water	1350000	kg	0.0019	2565.00	0.003753	5066.5500	water	1350000	kg	2565	5067	Helades sterilisation chemical	0	kg	4	0.00	2.61	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	13690	38753	0	3158	6851	10532	31902	Helades sterilisation chemical	40.5	kg	4	162.00	2.61	105.7050	Helades sterilisation chemical	-40	kg	-162	-105	71
415	\N	0.00	Tap water	510000.00	kg	0.0014680152671755724	748.69	4.580152671755725e-7	0.2336	1743.01	5	50	3	10.92	Tap water	450000	kg	0.0014680152671755724	660.61	4.580152671755725e-7	0.2061	1548.88	Tap Water	60000	kg	88.08000000000004	-194.12999999999988	0.027499999999999997	-774.97	0.27	Wasterwater treatment CH (Output)	510	m┬│	1.9496563254690695	994.32	0.0037154003343860304	1.8949	Wasterwater treatment CH (Output)	450.0	m┬│	1.9496563254690695	877.35	0.0037154003343860304	1.6719	Wasterwater treatment CH (Output)	60	m┬│	116.97000000000003	0.2230000000000001					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1743.01	2.1285	0	1537.96	1.8780	205.05	0.2505					0.00		0.0000		NaN		0	0	94
\N	335	0.00	nutritive biomass	38050	kg	0.1	3805.00	0.000004	0.1522	3805.00	5	40	0.1	8.02	nutritive biomass	38050	kg	-0.05	-1902.50	0	0.0000	-1894.48	nutritivebiomass	0	kg	5707.5	-5699.48	0.1522	-37447.31	0.01					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3805.00	0.1522	0	-1902.50	0.0000	5707.50	0.1522					0.00		0.0000		NaN		0	0	106
\N	364	0.00	nutritive biomass	38050	kg	0.1	3805.00	0.000004	0.1522	3805.00	10	500	0.1	50.28	nutritive biomass	38050	kg	-0.10	-3805.00		0.0000	-3754.72		0		7610	-7559.719999999999	0.1522	-49669.65	0.07					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3805.00	0.1522	0	-3805.00	0.0000	7610.00	0.1522					0.00		0.0000		NaN		0	0	113
488	\N	0.00	Dust emission	15.05	kg	0	0.00	0.14019933554817274	2.1100	0.00	20	2000000	3	134431.42	Dust emission	5.02	kg	 29880.5	150000.11	0.14019933554817274	0.7038	284431.53		10.030000000000001		-150000.11	284431.53	1.4062	202269.61	-17.92					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	2.1100	0	150000.11	0.7038	-150000.11	1.4062					0.00		0.0000		NaN		0	0	158
304	\N	0.00	rawmilk_losses	579063.00	kg	0.5500265083419248	318500.00	0.34905528414006765	202125.0000	318500.00				0	rawmilk_losses	0	kg	0.55	0.00	0.3949	0.0000	0	rawmilk_losses	579063	kg	318500	-318500	202125	-1.58	NaN					0.00		0.0000		0			0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	318500	202125	0	0	0	318500	202125					0.00		0.0000		NaN		0	0	77
\N	328	0.00	rawmilk_losses	579063	kg	0.55	318484.65	3.522	2039459.8860	318484.00				0	rawmilk_losses	578223	kg	0.55	318022.65	3.522	2036501.4060	318022	rawmilk_losses	840	kg	462	-462	2958	-0.16	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	318484	2039459	0	318022	2036501	462	2958					0.00		0.0000		NaN		0	0	78
338	\N	0.00	Electricity	600066.00	kWh	0.131	78608.65	0.5098	305913.6468	78608.00				0	Electricity	596366	kWh	0.131	78123.95	0.5098	304027.3868	78123		3700		485	-485	1886	-0.26	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	78608	305913	0	78123	304027	485	1886					0.00		0.0000		NaN		0	0	79
339	\N	0.00	district_heat	2371000.00	kWh	0.04301982285955293	102000.00	0.1361	322693.1000	102000.00	20	200000	5	16048.52	district_heat	1758540	kWh	0.043	75617.22	0.1361	239337.2940	91665	district_heat	612460	kWh	26383	-10335	83356	-0.12	12.17					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	102000	322693	0	75617	239337	26383	83356					0.00		0.0000		NaN		0	0	80
329	\N	0.00	co2	594599.00	t	37.57406924666876	22341504.00	460	273515540.0000	30098967.00	10	16000000	7.5	2330974.84	co2	518608	t	37.57406924666876	19486212.90	460	238559680.0000	27710896		75991		2855292	-2388071	34955860	-0.06	4.94	petcoke (Input)	70522000.00	kg	0.1100006097388049	7757463.00	0.021	1480962.0000	petcoke (Input)	47955000	kg	0.1100006097388049	5275079.24	0.021	1007055.0000	petcoke (Input)	22567000	kg	2482384	473907	plastic waste (Input)	0	kg	0.0049999781349208084	0.00	0.985	0.0000	plastic waste (Input)	26526316.00	kg	0.0049999781349208084	132631.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	-132631	-26128421	nitrogen_oxides (Output)	1501875.00	kg	0	0.00	41.864	62874495.0000	Dust (Output)	7101.00	kg	0	0.00	119.000	845019.0000	Dust (Output)	4178	kg	0	0.00	119.000	497182.0000	Dust (Output)	2923	kg	0	347837	ammonia (Input)	0	kg	0.1	0.00	2.060	0.0000	ammonia (Input)	4860000.00	kg	0.1	486000.00	2.060	10011600.0000	ammonia (Input)	-4860000	kg	-486000	-10011600	0	30098967	338716016	0	25379922	301353736	4719045	37362280	nitrogen_oxides (Output)	600750	kg	0	0.00	41.864	25149798.0000	nitrogen_oxides (Output)	901125	kg	0	37724697	76
340	\N	0.00	co2	594599.00	t	37.57406924666876	22341504.00	460	273515540.0000	22341504.00	10	16000000	7.5	2330974.84	co2	518608	t	37.57406924666876	19486212.90	460	238559680.0000	22937011		75991		2855292	595507	34955860	0.01	13.43	ammonia (Input)	0	kg	0.1	0.00	2.060	0.0000	ammonia (Input)	4860000.00	kg	0.1	486000.00	2.060	10011600.0000	ammonia (Input)	-4860000	kg	-486000	-10011600	nitrogen_oxides (Output)	1501875.00	kg	0	0.00	41.864	62874495.0000	nitrogen_oxides (Output)	600750	kg	0	0.00	41.864	25149798.0000	nitrogen_oxides (Output)	901125	kg	0	37724697	Electricity (Input)	0	kWh	0.1	0.00	0.233	0.0000	Dust (Output)	7101.00	kg	0	0.00	119	845019.0000	Dust (Output)	7101.00	kg	0	0.00	119	845019.0000	Dust (Output)	0	kg	0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	22341504	337235054	0	20606037	276042909	1735467	61192145	Electricity (Input)	6338250.00	kWh	0.1	633825.00	0.233	1476812.2500	Electricity (Input)	-6338250	kWh	-633825	-1476812	84
345	\N	0.00	Electricity	0	kWh	0.1	0.00	0.233	0.0000	0.00	10	6000000	7.5	874115.56	Electricity	0	kWh	0.1	0.00	0.233	0.0000	874115	Electricity	0	kWh	0	874115	0	2.51	Infinity	Dust (Output)	7101.00	kg	0	0.00	119	845019.0000	Dust (Output)	4178	kg	0	0.00	119	497182.0000	Dust (Output)	2923	kg	0	347837					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0	845019	0	0	497182	0	347837					0.00		0.0000		NaN		0	0	81
343	\N	0.00	petcoke	70522000.00	kg	0.1100006097388049	7757463.00	0.021	1480962.0000	30098967.00	20	15000000	7.5	1471382.87	petcoke	47955000	kg	0.110	5275050.00	0.021	1007055.0000	26332173		22567000		2482413	-3766794	473907	-0.39	5.62	co2 (Output)	594599.00	t	37.57406924666876	22341504.00	460	273515540.0000	co2 (Output)	517727	t	37.57406924666876	19453110.15	460	238154420.0000	co2 (Output)	76872	t	2888394	35361120	plastic waste (Input)	0	kg	0.0049999781349208084	0.00	0.985	0.0000	plastic waste (Input)	26526316.00	kg	0.0049999781349208084	132631.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	-132631	-26128421					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	30098967	274996502	0	24860791	265289896	5238176	9706606					0.00		0.0000		NaN		0	0	82
428	\N	0.00	Electricity CH medium Voltage	31702.00	kWh	0.40987950287048136	12994.00	0.00023342375875339097	7.4000	12994.00	20	0	3	0.00	Electricity CH medium Voltage	26418	kWh	0.40987950287048136	10828.20	0.00023342375875339097	6.1666	10828.2		5284		2165.7999999999993	-2165.7999999999993	1.2334000000000005	-1755.96	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	7.4000	0	10828.20	6.1666	2165.80	1.2334					0.00		0.0000		NaN		0	0	104
334	\N	0.00	ammonia	0	kg	0.1	0.00	2.060	0.0000	30098967.00	10	10000000	7.5	1456859.27	ammonia	4860000.00	kg	0.1	486000.00	2.060	10011600.0000	26806722		-4860000		-486000	-3292245	-10011600	-0.09	3.07	petcoke (Input)	70522000.00	kg	0.1100006097388049	7757463.00	0.021	1480962.0000	petcoke (Input)	47955000	kg	0.1100006097388049	5275079.24	0.021	1007055.0000	petcoke (Input)	22567000	kg	2482384	473907	co2 (Output)	594599.00	t	37.57406924666876	22341504.00	460	273515540.0000	co2 (Output)	517808	t	37.57406924666876	19456153.65	460	238191680.0000	co2 (Output)	76791	t	2885351	35323860	nitrogen_oxides (Output)	1501875.00	kg	0	0.00	41.864	62874495.0000	plastic waste (Input)	0	kg	0.0049999781349208084	0.00	0.985	0.0000	plastic waste (Input)	26526316.00	kg	0.0049999781349208084	132631.00	0.985	26128421.2600	plastic waste (Input)	-26526316	kg	-132631	-26128421					0.00		0.0000					0.00		0.0000		NaN		0	0	0	30098967	337870997	0	25349863	300488554	4749104	37382443	nitrogen_oxides (Output)	 600750 	kg	0	0.00	41.864	25149798.0000	nitrogen_oxides (Output)	901125	kg	0	37724697	75
350	\N	0.00	Electricity CH medium Voltage	1260000.00	kWh	1.873015873015873	2360000.00	233.43	294121800.0000	2360000.00	5	40000		0	Electricity CH medium Voltage	1100000.00	kWh	1.873015873015873	2060317.46	233.43	256773000.0000	2060317		160000		299683	-299683	37348800	-0.01	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2360000	294121800	0	2060317	256773000	299683	37348800					0.00		0.0000		NaN		0	0	86
347	\N	0.00	electricity_lv_rer	360000.00	kWh	6.555555555555555	2360000.00	509.8	183528000.0000	2360000.00	10	20000		0	electricity_lv_rer	260000.00	kWh	6.555555555555555	1704444.44	509.8	132548000.0000	1706982		100000		655556	-653018	50980000	-0.02	0.00	raw_milk (Input)	0	kg	0.5	0.00	3522	0.0000					0.00		0.0000		NaN		0	0	water (Input)	00.00	kg	0.0009402185185185185	0.00	3.753	0.0000	water (Input)	2700000.00	kg	0.0009402185185185185	2538.59	3.753	10133100.0000	water (Input)	-2700000	kg	-2538	-10133100					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2360000	183528000	0	1706982	142681100	653018	40846900					0.00		0.0000		NaN		0	0	85
348	\N	0.00	Electricity CH medium Voltage	270000.00	kWh	8.74074074074074	2360000.00	233.43	63026100.0000	2360000.00	10	60000		0	Electricity CH medium Voltage	10000.00	kWh	8.74074074074074	87407.41	233.43	2334300.0000	87407		260000		2272593	-2272593	60691800	-0.04	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2360000	63026100	0	87407	2334300	2272593	60691800					0.00		0.0000		NaN		0	0	87
357	\N	0.00	Raw Milk	60000.00	kg	0.55	33000.00	3.500	210000.0000	42780.00	0	0	5	0	Raw Milk	30000.00	kg	0.5	15000.00	3.5	105000.0000	19294	Raw Milk	30000	kg	18000	-23486	105000	-0.20	0.00	Water	941000	kg	0.0019	1787.90	0.00419	3942.7900	water	4710	kg	0.0019	8.95	0.00419	19.7349	Water	936290	kg	1779	3923	electricity	15000	kWh	0.131	1965.00	0.5	7500.0000	electricity	9300	kWh	0.131	1218.30	0.5098	4741.1400	electricity	5700	kWh	747	2759	Heat	8000	kWh	0.05	400.00	0.136	1088.0000	Phosphoric Acid	938	kg	3	2814.00	5.95	5581.1000	Phosphoric acid	469	kg	3	1407.00	5.95	2790.5500	Phosphoric acid	469	kg	1407	2791	Sodium hydroxid	938	kg	3	2814.00	1.58	1482.0400	Sodium hydroxid	469	kg	3	1407.00	1.58	741.0200	Sodium hydroxid	469	kg	1407	741	0	42780	229593	0	19294	113971	23486	115622	heat	5000	kWh	0.0508	254.00	0.136	680.0000	heat	3000	kWh	146	408	89
366	\N	0.00	Raw Milk Loss	300000.00	kg	0.55	165000.00	3.500	1050000.0000	2218035.00	30	500000	10	53039.62	Raw Milk	200.00	kg	0	0.00	3.500	700.0000	656874027	Raw Milk	299800	kg	165000	654655992	1049300	3.40	-0.00	Test1	45623		45	2053035.00	4255	194125865.0000	Test1	7778		84446	656820988.00	358	2784524.0000		37845		-654767953	191341341					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2218035	195175865	0	656820988	2785224	-654602953	192390641					0.00		0.0000		NaN		0	0	90
\N	375	0.00	nutritivebiomass	19000	kg	1	19000.00	0.003474	66.0060	19000.00	20	0	0	0	nutritivebiomass	19000	kg	0.5	9500.00	0.0034	64.6000	9500		0		9500	-9500	1.406000000000006	-6756.76	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	19000.00	66.0060	0	9500.00	64.6000	9500.00	1.4060					0.00		0.0000		NaN		0	0	129
349	\N	0.00	Electricity CH medium Voltage	270000.00	kWh	8.74074074074074	2360000.00	233.43	63026100.0000	2360000.00	20	80000		0	Electricity CH medium Voltage	13000.00	kWh	8.74074074074074	113629.63	233.43	3034590.0000	113629		257000		2246371	-2246371	59991510	-0.04	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	2360000	63026100	0	113629	3034590	2246371	59991510					0.00		0.0000		NaN		0	0	88
195	\N	0.00	MSWI heat	2005000.00	kWh	0.05087281795511222	102000.00	0.13610680160598505	272894.1372	102000.00	20	200000	5	16048.52	MSWI heat	2005000.00	kWh	0.0508	101854.00	0.1361068	272894.1340	117902	MSWI heat	0	kWh	146	15902	0	Infinity	2198.36			kWh		0.00		0.0000	(Input)		kWh		0.00		0.0000	district_heat_mswi (Input)	NaN	kWh	0	0					0.00		0.0000					0.00		0.0000	(Output)	NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	102000	272894	0	101854	272894	146	0					0.00		0.0000		NaN		0	0	31
400	\N	0.00	Electricity CH medium Voltage	49700.00	kWh	0.2614486921529175	12994.00	0.00023340040241448691	11.6000	12994.00	15	1000	3	83.77	Electricity CH medium Voltage	45000.00	kWh	0.2614486921529175	11765.19	0.00023340040241448691	10.5030	11848	Electricity	4700	kWh	1229	-1146	1	-1146.00	1.01	Electricity CH medium Voltage (Input)				0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994	11	0	11765	10	1229	1					0.00		0.0000		NaN		0	0	93
363	\N	0.00	Heat air water heat pump CH	136550.00	kWh	0.74697912852435	102000.00	0.13548150860490662	18500.0000	109095.00	15	50000	5	4817.11	Heat air water heat pump CH	19550.00	kWh	0.074697912852435	1460.34	0.13548150860490662	2648.6635	10815	district heat	117000	kWh	100540	-98280	15852	-3.70	0.70	Water (input)	2700000	kg	0.0019	5130.00	0.00419	11313.0000	water	1350000	kg	0.0019	2565.00	0.00419	5656.5000	water	1350000	kg	2565	5657	electricity	15000	kWh	0.131	1965.00	0.5	7500.0000	electricity	2700	kWh	0.131	353.70	0.5098	1376.4600	electricity	12300	kWh	1612	6124	desinf_chemical	0	kg	4	0.00	2.6	0.0000	Tes				0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	109095	37313	0	5998	10733	103097	26580	desinf_chemical	405	kg	4	1620.00	2.6	1053.0000	desinf_chemical	-405	kg	-1620	-1053	91
423	\N	0.00	Heat natural gas CH	905893.20	MJ	0.02589061271240363	23454.13	0.000018048485185670897	16.3500	23454.13	20	50000	3	3360.79	Heat natural gas CH	867344.5	MJ	0.02589061271240363	22456.08	0.000018048485185670897	15.6543	25816.870000000003		38548.69999999995		998.0499999999993	2362.7400000000016	0.6957000000000022	3396.21	67.35					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	23454.13	16.3500	0	22456.08	15.6543	998.05	0.6957					0.00		0.0000		NaN		0	0	99
\N	370	0.00	nutritive Biomass	19000	kg	0.0262	497.80	0.00347	65.9300	497.80	10	1000	3	117.23	nutritive biomass	19000	kg	0.00	0.00	0.002	38.0000	117.23		0		497.8	-380.57	27.930000000000007	-13.63	2.35					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	497.80	65.9300	0	0.00	38.0000	497.80	27.9300					0.00		0.0000		NaN		0	0	123
453	\N	0.00	Electricity CH medium Voltage	4696.42	kWh	2.766788319613663	12994.00	0.00023422095979490763	1.1000	12994.00	13	3218	3	302.59	Electricity CH medium Voltage	1331.00	kWh	2.766788319613663	3682.60	0.00023422095979490763	0.3117	3985.19		3365.42		9311.4	-9008.81	0.7883000000000001	-11428.15	0.42					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	1.1000	0	3682.60	0.3117	9311.40	0.7883					0.00		0.0000		NaN		0	0	124
449	\N	0.00	Electricity CH medium Voltage	49179.00	kWh	0.26	12786.54	0.00023343296935683932	11.4800	12786.54	20	1500	3	100.82	Electricity CH medium Voltage	40700	kWh	0.26	10582.00	0.00023343296935683932	9.5007	10682.82		8479		2204.540000000001	-2103.720000000001	1.9793000000000003	-1062.86	0.91					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12786.54	11.4800	0	10582.00	9.5007	2204.54	1.9793					0.00		0.0000		NaN		0	0	126
450	\N	0.00	Electricity CH medium Voltage	32955.00	kWh	0.26	8568.30	0.00023334850553785466	7.6900	8568.30	20	0	3	0.00	Electricity CH medium Voltage	27500	kWh	0.26	7150.00	0.00023334850553785466	6.4171	7150		5455		1418.2999999999993	-1418.2999999999993	1.2729000000000008	-1114.23	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	8568.30	7.6900	0	7150.00	6.4171	1418.30	1.2729					0.00		0.0000		NaN		0	0	127
451	\N	0.00	Electricity CH medium Voltage	4559.36	kWh	0.26	1185.43	0.00021494244806288603	0.9800	1185.43	15	1800	3	150.78	Electricity CH medium Voltage	2026.22	kWh	0.26	526.82	0.00021494244806288603	0.4355	677.6		2533.1399999999994		658.61	-507.83000000000004	0.5445	-932.65	3.43					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1185.43	0.9800	0	526.82	0.4355	658.61	0.5445					0.00		0.0000		NaN		0	0	128
452	\N	0.00	Electricity CH medium Voltage	2763.25	kWh	0.26	718.45	0.00021351669230073282	0.5900	718.45	20	5000	3	336.08	Electricity CH medium Voltage	1842	kWh	0.26	478.92	0.00021351669230073282	0.3933	815		921.25		239.53000000000003	96.54999999999995	0.19669999999999999	490.85	28.06					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	718.45	0.5900	0	478.92	0.3933	239.53	0.1967					0.00		0.0000		NaN		0	0	125
\N	376	0.00	Electricity CH medium Voltage	55265	kWh	0.26	14368.90	0.0002125	11.7438	14368.90	30	53485	3	2728.77	Electricity CH medium Voltage	55265	kWh		0.00	0.00015	8.2897	2728.77		0		14368.9	-11640.13	3.4541000000000004	-3369.95	5.70					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14368.90	11.7438	0	0.00	8.2897	14368.90	3.4541					0.00		0.0000		NaN		0	0	130
456	\N	0.00	Electricity CH medium Voltage	46192.00	kWh	0.07403879459646692	3420.00	0.0002333737443713197	10.7800	3420.00	15	15000	2	1167.38	Electricity CH medium Voltage	40000	kWh	0.07403879459646692	2961.55	0.0002333737443713197	9.3349	4128.93		6192		458.4499999999998	708.9300000000003	1.4451	490.58	38.20					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3420.00	10.7800	0	2961.55	9.3349	458.45	1.4451					0.00		0.0000		NaN		0	0	131
459	\N	0.00	Electricity CH medium Voltage	44805.85	kWh	0.31245919896620644	14000.00	0.00024059358320397894	10.7800	14000.00	20	1500	3	100.82	Electricity CH medium Voltage	36445.85	kWh	0.31245919896620644	11387.84	0.00024059358320397894	8.7686	11488.66		8360		2612.16	-2511.34	2.0114	-1248.55	0.77					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14000.00	10.7800	0	11387.84	8.7686	2612.16	2.0114					0.00		0.0000		NaN		0	0	135
447	\N	0.00	Barley grain	37680.00	kg	0.18577494692144372	7000.00	0.003464171974522293	130.5300	7000.00	100	5000	3	158.23	Barley grain	34665.00	kg	0.18577494692144372	6439.89	0.003464171974522293	120.0855	6598.12		3015		560.1099999999997	-401.8800000000001	10.444500000000005	-38.48	28.25					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	7000.00	130.5300	0	6439.89	120.0855	560.11	10.4445					0.00		0.0000		NaN		0	0	121
458	\N	0.00	Heat natural gas CH	181322.60	MJ	0.12960325960470453	23500.00	0.000018034155698186546	3.2700	23500.00	15	25000	3	2094.16	Heat natural gas CH	154124	MJ	0.12960325960470453	19974.97	0.000018034155698186546	2.7795	22069.13		27198.600000000006		3525.029999999999	-1430.869999999999	0.49049999999999994	-2917.17	8.91					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	23500.00	3.2700	0	19974.97	2.7795	3525.03	0.4905					0.00		0.0000		NaN		0	0	134
466	\N	0.00	Electricity CH medium Voltage	4494.41	kWh	2.891147002609909	12994.00	0.0002135986703482771	0.9600	12994.00	13	3218	3	302.59	Electricity CH medium Voltage	1331	kWh	2.891147002609909	3848.12	0.0002135986703482771	0.2843	4150.71		3163.41		9145.880000000001	-8843.29	0.6757	-13087.60	0.43					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	0.9600	0	3848.12	0.2843	9145.88	0.6757					0.00		0.0000		NaN		0	0	141
464	\N	0.00	Electricity CH medium Voltage	49205.19	kWh	0.264077834065878	12994.00	0.0002125792015029309	10.4600	12994.00	20	1500	3	100.82	Electricity CH medium Voltage	40810	kWh	0.264077834065878	10777.02	0.0002125792015029309	8.6754	10877.84		8395.190000000002		2216.9799999999996	-2116.16	1.784600000000001	-1185.79	0.91					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	10.4600	0	10777.02	8.6754	2216.98	1.7846					0.00		0.0000		NaN		0	0	142
463	\N	0.00	Barley grain	37680.00	kg	0.18577494692144372	7000.00	0.003464171974522293	130.5300	7000.00	100	5000	3	158.23	Barley grain	34665	kg	0.18577494692144372	6439.89	0.003464171974522293	120.0855	6598.12		3015		560.1099999999997	-401.8800000000001	10.444500000000005	-38.48	28.25					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	7000.00	130.5300	0	6439.89	120.0855	560.11	10.4445					0.00		0.0000		NaN		0	0	143
467	\N	0.00	Electricity CH medium Voltage	1191.00	kWh	10.910159529806885	12994.00	0.0090512174643157	10.7800	12994.00	20	20000	3	1344.31	Electricity CH medium Voltage	356	kWh	10.910159529806885	3884.02	0.0090512174643157	3.2222	5228.33		835		9109.98	-7765.67	7.557799999999999	-1027.50	2.95					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	10.7800	0	3884.02	3.2222	9109.98	7.5578					0.00		0.0000		NaN		0	0	139
457	\N	0.00	Heat natural gas CH	181322.60	MJ	0.12960325960470453	23500.00	0.000018034155698186546	3.2700	23500.00	15	25000	3	2094.16	Heat natural gas CH	154124	MJ	0.12960325960470453	19974.97	0.000018034155698186546	2.7795	22069.13		27198.600000000006		3525.029999999999	-1430.869999999999	0.49049999999999994	-2917.17	8.91					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	23500.00	3.2700	0	19974.97	2.7795	3525.03	0.4905					0.00		0.0000		NaN		0	0	132
460	\N	0.00	Electricity CH medium Voltage	3810.81	kWh	3.6737596468992155	14000.00	0.00023354614898145015	0.8900	14000.00	10	1000	3	117.23	Electricity CH medium Voltage	2800	kWh	3.6737596468992155	10286.53	0.00023354614898145015	0.6539	10403.76		1010.81		3713.4699999999993	-3596.24	0.23609999999999998	-15231.85	0.32					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14000.00	0.8900	0	10286.53	0.6539	3713.47	0.2361					0.00		0.0000		NaN		0	0	136
462	\N	0.00	Electricity CH medium Voltage	30024.54	kWh	0.4662852453359818	14000.00	0.0002334756835575166	7.0100	14000.00	50	0	3	0.00	Electricity CH medium Voltage	24744	kWh	0.4662852453359818	11537.76	0.0002334756835575166	5.7771	11537.76		5280.540000000001		2462.24	-2462.24	1.2328999999999999	-1997.11	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14000.00	7.0100	0	11537.76	5.7771	2462.24	1.2329					0.00		0.0000		NaN		0	0	137
461	\N	0.00	Electricity CH medium Voltage	2309.58	kWh	6.0617081893677645	14000.00	0.00023380874444704235	0.5400	14000.00	20	75000	3	5041.18	Electricity CH medium Voltage	1539	kWh	6.0617081893677645	9328.97	0.00023380874444704235	0.3598	14370.15		770.5799999999999		4671.030000000001	370.14999999999964	0.18020000000000003	2054.11	21.58					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	14000.00	0.5400	0	9328.97	0.3598	4671.03	0.1802					0.00		0.0000		NaN		0	0	138
469	\N	0.00	Electricity CH medium Voltage	50727.00	kWh	0.25615549904390167	12994.00	0.00021251010310091272	10.7800	12994.00	30	32350	3	1650.47	Electricity CH medium Voltage	39225	kWh	0.25615549904390167	10047.70	0.00021251010310091272	8.3357	11698.17		11502		2946.2999999999993	-1295.83	2.4443	-530.14	16.81					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	10.7800	0	10047.70	8.3357	2946.30	2.4443					0.00		0.0000		NaN		0	0	146
\N	380	0.00	Nutritive Biomass	19000	kg	0.0526315	1000.00	0.0034736842105	66.0000	1000.00	10	5000	2.5	571.29	Nutritive Biomass	19000	kg	-0.10	-1900.00	0	0.0000	-1328.71		0		2900	-2328.71	66	-35.28	1.97					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1000.00	66.0000	0	-1900.00	0.0000	2900.00	66.0000					0.00		0.0000		NaN		0	0	144
468	\N	0.00	Electricity CH medium Voltage	1191.00	kWh	10.910159529806885	12994.00	0.0090512174643157	10.7800	12994.00	20	20000	3	1344.31	Electricity CH medium Voltage	356	kWh	10.910159529806885	3884.02	0.0090512174643157	3.2222	5228.33		835		9109.98	-7765.67	7.557799999999999	-1027.50	2.95					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	10.7800	0	3884.02	3.2222	9109.98	7.5578					0.00		0.0000		NaN		0	0	145
465	\N	0.00	Electricity CH medium Voltage	9409.86	kWh	1.380891958010002	12994.00	0.00021254301339233527	2.0000	12994.00				0	Electricity CH medium Voltage	4800	kWh	1.380891958010002	6628.28	0.00021254301339233527	1.0202	6628.28		4609.860000000001		6365.72	-6365.72	0.9798	-6496.96	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12994.00	2.0000	0	6628.28	1.0202	6365.72	0.9798					0.00		0.0000		NaN		0	0	140
470	\N	0.00	Barley grain	19200.00	kg	0.78125	15000.00	0.0034640625	66.5100	15000.00	1	1000	0.1	1001.00	Barley grain	0	kg	0.78125	0.00	0.0034640625	0.0000	1001		19200		15000	-13999	66.51	-210.48	0.07					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	15000.00	66.5100	0	0.00	0.0000	15000.00	66.5100					0.00		0.0000		NaN		0	0	147
\N	379	0.00	nutritivebiomass	19200	kg	0.10	1920.00		0.0000	1920.00	50	0	3	0.00	nutritivebiomass	-19200	kg	0.20	-3840.00		0.0000	-3840		38400		5760	-5760	0	-Infinity	0.00					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1920.00	0.0000	0	-3840.00	0.0000	5760.00	0.0000					0.00		0.0000		NaN		0	0	148
\N	392	0.00	Wheat Output	19000	kg	0.052632	1000.01		0.0000	1000.01	10	5000	2.5	571.29	Wheat Output	19000	kg	-0.10	-1900.00	0	0.0000	-1328.71		0		2900.01	-2328.7200000000003	0	-Infinity	1.97					0.00		0.0000					0.00		0.0000		NaN		0	0			kg		0.00		0.0000					0.00	0.003464171974522293	0.0000	Barley grain (Input)	NaN	kg	0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1000.01	0.0000	0	-1900.00	0.0000	2900.01	0.0000					0.00		0.0000		NaN		0	0	149
442	\N	0.00	Electricity CH medium Voltage	4494.41	kWh	0.25615549904390167	1151.27	0.0002135986703482771	0.9600	1151.27	13	3218	3	302.59	Electricity CH medium Voltage	1331.00	kWh	0.25615549904390167	340.94	0.0002135986703482771	0.2843	643.53		3163.41		810.3299999999999	-507.74	0.6757	-751.43	4.85					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1151.27	0.9600	0	340.94	0.2843	810.33	0.6757					0.00		0.0000		NaN		0	0	115
472	\N	0.00	Milk	40000.00	kg	0.5	20000.00	0.0002	8.0000	20000.00	15	50000	1	3606.19	Milk	10000	kg	0.5	5000.00	0.0002	2.0000	8606.19	Milk losses	30000	kg	15000	-11393.81	6	-1898.97	3.61	Milk (Input)	0	kg	0	0.00	0	0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	20000.00	8.0000	0	5000.00	2.0000	15000.00	6.0000					0.00		0.0000		NaN		0	0	150
474	\N	0.00	Water ukr	10000000.00	kg	0.001	10000.00	9.2e-7	9.2000	10000.00	20	20000	10	2349.19	Water ukr	1000000.00	kg	0.001	1000.00	9.2e-7	0.9200	3349.19		9000000		9000	-6650.8099999999995	8.28	-803.24	5.22					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	10000.00	9.2000	0	1000.00	0.9200	9000.00	8.2800					0.00		0.0000		NaN		0	0	151
\N	408	0.00	waste water alkaline	100000	kg	0.1	10000.00	9.2e-7	0.0920	10000.00	20	50000	10	5872.98	waste water alkaline	50000	kg	-0.05	-2500.00	9.2e-7	0.0460	3372.9799999999996	waste water alkaline 	50000	kg	12500	-6627.02	0.046	-144065.65	9.40					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	10000.00	0.0920	0	-2500.00	0.0460	12500.00	0.0460					0.00		0.0000		NaN		0	0	152
477	\N	0.00	Fernwrme	1185500.00	kWh	0.08603964571910586	102000.00	0.00013630535638970898	161.5900	102000.00	10	20000	2	2226.53	Fernwrme	118550.00	kWh	0.08603964571910586	10200.00	0.00013630535638970898	16.1590	15426.53	District Heat	1066950	kWh	91800	-86573.47	145.431	-603.59	0.25		0			0.00		0.0000	Helades	1000	kg	3	3000.00	0.002	2.0000	Helades	-1000	kg	-3000	-2					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	102000.00	161.5900	0	13200.00	18.1590	88800.00	143.4310					0.00		0.0000		NaN		0	0	153
481	\N	0.00	MSW transport	120000.00	t	10	1200000.00	0	0.0000	1200000.00	20	100000	3	6721.57	MSW transport	120000.00	t	10	1200000.00	0	0.0000	1206721.57		0		0	6721.570000000065	0	Infinity	Infinity					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1200000.00	0.0000	0	1200000.00	0.0000	0.00	0.0000					0.00		0.0000		NaN		0	0	155
479	\N	0.00	RDF burning	80000.00	t	0.0000375	3.00	0.000001375	0.1100	3.00				0	RDF burning	80000.00	t	0.0000375	3.00	0.000001375	0.1100	3		0		0	0	0	NaN	NaN					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	3.00	0.1100	0	3.00	0.1100	0.00	0.0000					0.00		0.0000		NaN		0	0	156
491	\N	0.00	NOx Emission	250.87	kg	0	0.00	0.03898433451588472	9.7800	0.00	20	2000000	3	134431.42	NOx Emission	100.35	kg	1076.261732	108002.86	0.03898433451588472	3.9121	242434.28000000003		150.52		-108002.86	242434.28000000003	5.867899999999999	41315.34	-24.89					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	9.7800	0	108002.86	3.9121	-108002.86	5.8679					0.00		0.0000		NaN		0	0	159
489	\N	0.00	NOx Emission	250.87	kg	0	0.00	0.03898433451588472	9.7800	0.00	20	1000000	3	67215.71	NOx Emission	100.35	kg	1076.24	108000.68	0.03898433451588472	3.9121	175216.39	a	150.52	a	-108000.68	175216.39	5.867899999999999	29860.15	-12.45					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	9.7800	0	108000.68	3.9121	-108000.68	5.8679					0.00		0.0000		NaN		0	0	157
490	\N	0.00	Dust emission	15.05	kg	0	0.00	0.14019933554817274	2.1100	0.00	20	2000000	3	134431.42	Dust emission	5.02	kg	29896.15922	150078.72	0.14019933554817274	0.7038	284510.14		10.030000000000001		-150078.72	284510.14	1.4062	202325.52	-17.91					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	2.1100	0	150078.72	0.7038	-150078.72	1.4062					0.00		0.0000		NaN		0	0	160
493	\N	0.00	NOx Emission	97135	kg	0	0.00	3.906432179753281e-7	0.0379	0.00	20	 1000000.00 	3	67215.71	NOx Emission	39135	kg	0.043050469	1684.78	3.906432179753281e-7	0.0153	68900.49		58000		-1684.78	68900.49	0.022600000000000002	3048694.25	-797.92					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	0.0379	0	1684.78	0.0153	-1684.78	0.0226					0.00		0.0000		NaN		0	0	161
501	\N	0.00	NOx Emission	2508683.00	kg	0	0.00	0.039	97838.6370	0.00	35	6466280	3	300936.09	NOx Emission	 1003473.38 	kg	0.06	60208.40	0.039	39135.4618	1852376.81		1505209.62		-60208.4	1852376.81	58703.175200000005	33.08	-6.79	Electricity	0	MWh	0	0.00	0	0.0000	Electricity	7135.312	MWh	200	1427062.40	0.022125	157.8688		-7135.312		-1427062.4	-157.8688	Ammonia	0	kg	0	0.00	0	0.0000	Ammonia	1332738.086	kg	0.048148935	64169.92	0.00191	2545.5297		-1332738.086		-64169.92	-2545.5297					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	97838.6370	0	1551440.72	41838.8603	-1551440.72	55999.7767					0.00		0.0000		NaN		0	0	166
478	\N	0.00	Petcoke Consumption Baseline	180000.00	t	73.63636363636364	13254545.45	1.35	243000.0000	13254545.45	20	14000000	3	941019.91	Petcoke Consumption Baseline	140000	t	73.63636363636364	10309090.91	1.35	189000.0000	13250110.82		40000		2945454.539999999	-4434.629999998957	54000	-0.08	19.91	RDF burning (Input)	0	t	0.0000375	0.00	0.000001375	0.0000	RDF burning (Input)	80000.00	t	8	640000.00	0.000001375	0.1100	RDF burning (Input)	-80000	t	-640000	-0.11	Electricity RDF (Input)	0	MWh	200	0.00	0	0.0000	Electricity RDF (Input)	800.00	MWh	200	160000.00	0	0.0000	Electricity RDF (Input)	-800	MWh	-160000	0	MSW transport (Input)	0	t	10	0.00	0	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	13254545.45	243000.0000	0	12309090.91	189000.1100	945454.54	53999.8900	MSW transport (Input)	120000.00	t	10	1200000.00	0	0.0000	MSW transport (Input)	-120000	t	-1200000	0	154
492	\N	0.00	Dust emission	150521.00	kg	0	0.00	0.000001395154164535181	0.2100	0.00	20	 2000000.00 	3	134431.42	Dust emission	150521.00	kg	0.996538641	149999.99	0.000001395154164535181	0.2100	284431.41000000003		0		-149999.99	284431.41000000003	0	Infinity	-17.92					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	0.2100	0	149999.99	0.2100	-149999.99	0.0000					0.00		0.0000		NaN		0	0	162
500	\N	0.00	Oil heating	167779.00	kWh	0.0765888460415189	12850.00	0.0002205281948277198	37.0000	12850.00	25	30000	5	2128.57	Oil heating	0	kWh	0.0765888460415189	0.00	0.0002205281948277198	0.0000	13680.15		167779		12850	830.1499999999996	37	22.58	40.98					0.00		0.0000	District Heating	151001	kWh	0.0765	11551.58	0.00000159	0.2401		NaN		-11551.58	-0.2401					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	12850.00	37.0000	0	11551.58	0.2401	1298.42	36.7599					0.00		0.0000		NaN		0	0	163
560	\N	0.00	Dust	150521.00	kg	0	0.00	0.14	21072.9400	0.00	35	70000	3	3257.75	Dust	50173.67	kg	2.12	106368.18	0.14	7024.3138	3331267.93		100347.33		-106368.18	3331267.93	14048.626199999999	243.30	-0.03	Electricity	0	KWh	0	0.00	0.022125	0.0000	Electricity	16108.21	KWh	200	3221642.00	0.022125	356.3941		-16108.21		-3221642	-356.3941					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	21072.9400	0	3328010.18	7380.7079	-3328010.18	13692.2321					0.00		0.0000		NaN		0	0	171
502	\N	0.00	Dust emission	150521.00	kg	0	0.00	0.14	21072.9400	0.00	35	9810059.6	3	456553.22	Dust emission	 50173.67 	kg	2.04	102354.29	0.14	7024.3138	3137707.51		100347.33		-102354.29	3137707.51	14048.626199999999	227.98	-5.96	Electricity	0	MWh	0	0.00	0	0.0000	Electricity	12894	MWh	200	2578800.00	0.022125	285.2797		-12894	kg	-2578800	-285.2797					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	21072.9400	0	2681154.29	7309.5935	-2681154.29	13763.3465					0.00		0.0000		NaN		0	0	165
486	\N	0.00	Fernwrme	109102.50	kWh/a	0.043	4691.41	0.1363	14870.6708	48795.58	0	0	0	0	Fernwrme	172046.25	kWh/a	0.043	7397.99	0.1363	23449.9039	33669.83	Fernwrme	-62943.75	kWh/a	-2706.58	-15125.75	-8579.233100000001	-0.09	0.00	Milchverlust	57750	kg/a	0.55	31762.50	4.71	272002.5000	Milchverluste	16500	kg/a	0.55	9075.00	4.71	77715.0000	Milchverluste	41250	kg/a	22687.5	194287.5	Lauge	940.5	kg/a	0.35	329.17	1.619	1522.6695	Lauge	470.25	kg/a	0.35	164.59	1.619	761.3347	Lauge	470.25	kg/a	164.58	761.3348	S├ñure	940.5	kg/a	1	940.50	5.277	4963.0185	Wasser	940.5	m^3/a	1.9	1786.95	4.198	3948.2190	Wasser	470.25	m^3/a	1.9	893.47	4.198	1974.1095	Wasser	470.25	m^3/a	893.48	1974.1095	Strom	70878.26087	kWh/a	0.131	9285.05	0.510	36147.9130	Strom	119607.07	kWh/a	0.131	15668.53	0.510	60999.6057	Strom	-48728.80913000001	kWh/a	-6383.480000000001	-24851.6927	0	48795.58	333454.9908	0	33669.83	167381.4631	15125.75	166073.5277	S├ñure	470.25	kg/a	1	470.25	5.277	2481.5093	S├ñure	470.25	kg/a	470.25	2481.5092	164
559	\N	0.00	Petcoke	180000.00	t	405.48	72986400.00	1.35	243000.0000	72986400.00	20	14000000.00	3	941019.91	Petcoke	140615	t	405.48	57016570.20	1.35	189830.2500	59957590.11		39385		15969829.799999997	-13028809.89	53169.75	-558.10	1.35	Electricity	0	KWh	0	0.00	0	0.0000	Electricity	800	MWh	200.00	160000.00	0.022125	17.7000		-800		-160000	-17.7	MSW Transport	0	t	0	0.00	0	0.0000	MSW Transport	120000	t	10.00	1200000.00	0.248	29760.0000		-120000		-1200000	-29760	RDF Burning	0	t	0	0.00	0	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	72986400.00	243000.0000	0	59016570.20	219655.1500	13969829.80	23344.8500	RDF Burning	80000	t	8	640000.00	0.00059	47.2000		-80000		-640000	-47.2	169
\N	412	0.00	RDF Burning	0	t	0	0.00	0	0.0000	72986400.00	20	14000000.00	3	941019.91	RDF Burning	80000	t	8	640000.00	0.00059	47.2000	59957590.11		-80000		-640000	-13028809.89	-47.2	-558.10	1.35	MSW Transport	0	t	0	0.00	0	0.0000	MSW Transport	120000	t	10	1200000.00	0.248	29760.0000		-120000		-1200000	-29760	Electricity	0	KWh	0	0.00	0	0.0000	Electricity	800	KWh	200	160000.00	0.022125	17.7000		-800		-160000	-17.7	Petcoke	180000.00	t	405.48	72986400.00	1.35	243000.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	72986400.00	243000.0000	0	59016570.20	219655.1500	13969829.80	23344.8500	Petcoke	140615	t	405.48	57016570.20	1.35	189830.2500		39385		15969829.799999997	53169.75	170
514	\N	0.00	NOx	2508683.00	kg	0	0.00	0.039	97838.6370	0.00	35	6466280	3	300936.09	NOx	1003473	kg	0.05547326	55665.92	0.039	39135.4470	1847833.9300000002		1505210		-55665.92	1847833.9300000002	58703.19	32.99	-6.81	Ammonia	0	kg	0	0.00	0	0.0000	NH3	1332738.09	kg	0.048148935	64169.92	0.00191	2545.5298		-1332738.09		-64169.92	-2545.5298	Electricity	0	kWh	0	0.00	0	0.0000	Electricity	7135.31	kWh	200	1427062.00	0.02	142.7062		-7135.31		-1427062	-142.7062					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	97838.6370	0	1546897.84	41823.6830	-1546897.84	56014.9540					0.00		0.0000		NaN		0	0	167
487	\N	0.00	nichts 	0	0	0	0.00	0	0.0000	31762.50	10	50000	0.001	5000.28	OPEX	0	CHF	0	0.00	0	0.0000	11352.779999999999	OPEX	0	CHF	0	-20409.72	0	-0.13	1.97	Milchverluste	57750	kg/a	0.55	31762.50	3.522	203395.5000	Milchverluste	11550	kg/a	0.55	6352.50	3.522	40679.1000	Milchverluste	46200	kg/a	25410	162716.4					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	31762.50	203395.5000	0	6352.50	40679.1000	25410.00	162716.4000					0.00		0.0000		NaN		0	0	172
561	\N	0.00	Biogas	0	GJ	30.28	0.00	0	0.0000	72986400.00	20	14000000.00	3	941019.91	Biogas	1280000.00	GJ	30.28	38758400.00	1.71E-05	21.8880	96715990.11		-1280000		-38758400	23729590.11	-21.888	446.48	-0.83	Petcoke	180000.00	t	405.48	72986400.00	1.35	243000.0000	Petcoke	140615	t	405.48	57016570.20	1.35	189830.2500		39385		15969829.799999997	53169.75					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	72986400.00	243000.0000	0	95774970.20	189852.1380	-22788570.20	53147.8620					0.00		0.0000		NaN		0	0	173
482	\N	0.00	Fernwrme	150334	kWh/a	0.043	6464.36	0.1363	20490.5242	13691.80	15	50000	0.001	3333.60	Fernwrme	47092.5 	kWh/a	0.043	2024.98	0.1363	6418.7078	15692.83	Fernwrme	103241.5	kWh/a	4439.379999999999	2001.0300000000007	14071.8164	0.10	37.52	Wasser	2700	m^3/a	1.9	5130.00	0.446	1204.2000	Wasser	2700	m^3/a	1.9	5130.00	0.446	1204.2000		0	m^3/a	0	0	Strom	16011	kWh/a	0.131	2097.44	0.510	8165.6100	Strom	0	kWh/a	0.131	0.00	0.510	0.0000		16011		2097.44	8165.61	Halades 15P	0	m^3/a	6425	0.00	2610	0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	13691.80	29860.3342	0	12359.23	9737.0078	1332.57	20123.3264	Halades 15P	0.81	m^3/a	6425	5204.25	2610	2114.1000		-0.81		-5204.25	-2114.1	177
513	\N	0.00	Dust	150521.00	kg	0	0.00	0.14	21072.9400	0.00	35	60000	3	2792.36	Dust	50173.67	kg	2.04	102354.29	0.14	7024.3138	2683962.65		100347.33		-102354.29	2683962.65	14048.626199999999	194.62	-0.04	Electricity	0	kWh	0	0.00	0	0.0000	Electricity	12894.08	kWh	200	2578816.00	0.02	257.8816		-12894.08		-2578816	-257.8816					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	0.00	21072.9400	0	2681170.29	7282.1954	-2681170.29	13790.7446					0.00		0.0000		NaN		0	0	168
483	\N	0.00	Fernwrme Ges	2371000	kWh/a	0.043	101953.00	0.1363	323167.3000	101953.00	10	15000	0.001	1500.08	Fernwrme Ges	1939377	kWh/a	0.043	83393.21	0.1363	264337.0851	84893.29000000001		431623		18559.789999999994	-17059.709999999992	58830.21489999996	-0.29	0.81					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	101953.00	323167.3000	0	83393.21	264337.0851	18559.79	58830.2149					0.00		0.0000		NaN		0	0	176
485	\N	0.00	nichts	0	kg	0	0.00	0	0.0000	31762.50	15	16000	1	1153.98	Verdampfungsenergie	59396	kWh/a	0.043	2554.03	0.1363	8095.6748	3708.01	Verdampfungsenergie	-59396	kWh/a	-2554.03	-28054.489999999998	-8095.6748	-0.14	0.59	Milchverluste	57750	kg/a	0.55	31762.50	3.522	203395.5000	Milchverluste	0	kg/a	0.55	0.00	3.522	0.0000	Milchverluste	57750	kg/a	31762.5	203395.5					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000	Verdampfungsenergie	NaN	kWh/a	0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	31762.50	203395.5000	0	2554.03	8095.6748	29208.47	195299.8252					0.00		0.0000		NaN		0	0	174
562	\N	0.00	Electricity CH medium Voltage	3000000.00	kWh	0.357749	1073247.00	0.00069591	2087.7300	1608247.00	25	200000	1	9081.35	Electricity CH medium Voltage	2000000.00	kWh	0.357749	715498.00	0.00069591	1391.8200	1152579.35	Electricity CH medium Voltage	1000000		357749	-455667.6499999999	695.9100000000001	-654.76	0.49	Tapwater	500000	t	1.07	535000.00	0.00000018	0.0900	Tapwater	400000	t	1.07	428000.00	0.00000018	0.0720	Tapwater	100000		107000	0.018000000000000002					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	1608247.00	2087.8200	0	1143498.00	1391.8920	464749.00	695.9280					0.00		0.0000		NaN		0	0	178
484	\N	0.00	Milchverluste	57750	kg/a	0.55	31762.50	3.522	203395.5000	31762.50	10	50000	0.001	5000.28	Milchverluste	11550	kg/a	0.55	6352.50	3.522	40679.1000	29832.78	Milchverluste	46200	kg/a	25410	-1929.7200000000012	162716.4	-0.01	7.22					0.00		0.0000					0.00		0.0000		NaN	kg/a	0	0					0.00		0.0000	Milchverkauf	46200	kg/a	0.4	18480.00	0	0.0000		NaN		-18480	0					0.00		0.0000					0.00		0.0000					0.00		0.0000		NaN		0	0					0.00		0.0000					0.00		0.0000		NaN		0	0	0	31762.50	203395.5000	0	24832.50	40679.1000	6930.00	162716.4000					0.00		0.0000		NaN		0	0	175
\.


--
-- Data for Name: t_country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_country (id, iso, name, printable_name, iso3, numcode) FROM stdin;
1	AF	AFGHANISTAN	Afghanistan	AFG	4
2	AL	ALBANIA	Albania	ALB	8
3	DZ	ALGERIA	Algeria	DZA	12
4	AS	AMERICAN SAMOA	American Samoa	ASM	16
5	AD	ANDORRA	Andorra	AND	20
6	AO	ANGOLA	Angola	AGO	24
7	AI	ANGUILLA	Anguilla	AIA	660
8	AQ	ANTARCTICA	Antarctica	\N	\N
9	AG	ANTIGUA AND BARBUDA	Antigua and Barbuda	ATG	28
10	AR	ARGENTINA	Argentina	ARG	32
11	AM	ARMENIA	Armenia	ARM	51
12	AW	ARUBA	Aruba	ABW	533
13	AU	AUSTRALIA	Australia	AUS	36
14	AT	AUSTRIA	Austria	AUT	40
15	AZ	AZERBAIJAN	Azerbaijan	AZE	31
16	BS	BAHAMAS	Bahamas	BHS	44
17	BH	BAHRAIN	Bahrain	BHR	48
18	BD	BANGLADESH	Bangladesh	BGD	50
19	BB	BARBADOS	Barbados	BRB	52
20	BY	BELARUS	Belarus	BLR	112
21	BE	BELGIUM	Belgium	BEL	56
22	BZ	BELIZE	Belize	BLZ	84
23	BJ	BENIN	Benin	BEN	204
24	BM	BERMUDA	Bermuda	BMU	60
25	BT	BHUTAN	Bhutan	BTN	64
26	BO	BOLIVIA	Bolivia	BOL	68
27	BA	BOSNIA AND HERZEGOVINA	Bosnia and Herzegovina	BIH	70
28	BW	BOTSWANA	Botswana	BWA	72
29	BV	BOUVET ISLAND	Bouvet Island	\N	\N
30	BR	BRAZIL	Brazil	BRA	76
31	IO	BRITISH INDIAN OCEAN TERRITORY	British Indian Ocean Territory	\N	\N
32	BN	BRUNEI DARUSSALAM	Brunei Darussalam	BRN	96
33	BG	BULGARIA	Bulgaria	BGR	100
34	BF	BURKINA FASO	Burkina Faso	BFA	854
35	BI	BURUNDI	Burundi	BDI	108
36	KH	CAMBODIA	Cambodia	KHM	116
37	CM	CAMEROON	Cameroon	CMR	120
38	CA	CANADA	Canada	CAN	124
39	CV	CAPE VERDE	Cape Verde	CPV	132
40	KY	CAYMAN ISLANDS	Cayman Islands	CYM	136
41	CF	CENTRAL AFRICAN REPUBLIC	Central African Republic	CAF	140
42	TD	CHAD	Chad	TCD	148
43	CL	CHILE	Chile	CHL	152
44	CN	CHINA	China	CHN	156
45	CX	CHRISTMAS ISLAND	Christmas Island	\N	\N
46	CC	COCOS (KEELING) ISLANDS	Cocos (Keeling) Islands	\N	\N
47	CO	COLOMBIA	Colombia	COL	170
48	KM	COMOROS	Comoros	COM	174
49	CG	CONGO	Congo	COG	178
50	CD	CONGO, THE DEMOCRATIC REPUBLIC OF THE	Congo, the Democratic Republic of the	COD	180
51	CK	COOK ISLANDS	Cook Islands	COK	184
52	9 	28-TRIAL-COSTA RICA 46	46-TRIAL-Costa Rica 273	18 	188
53	2 	222-TRIAL-COTE D'IVOIRE 244	95-TRIAL-Cote D'Ivoire 40	77 	384
54	1 	92-TRIAL-CROATIA 114	229-TRIAL-Croatia 160	68 	191
55	1 	52-TRIAL-CUBA 13	53-TRIAL-Cuba 252	69 	192
56	2 	196-TRIAL-CYPRUS 236	39-TRIAL-Cyprus 78	10 	196
57	9 	106-TRIAL-CZECH REPUBLIC 116	286-TRIAL-Czech Republic 177	68 	203
58	1 	145-TRIAL-DENMARK 270	113-TRIAL-Denmark 248	79 	208
59	1 	114-TRIAL-DJIBOUTI 65	23-TRIAL-Djibouti 117	26 	262
60	2 	245-TRIAL-DOMINICA 278	284-TRIAL-Dominica 235	18 	212
61	2 	274-TRIAL-DOMINICAN REPUBLIC 286	78-TRIAL-Dominican Republic 8	25 	214
62	1 	227-TRIAL-ECUADOR 195	213-TRIAL-Ecuador 256	28 	218
63	2 	68-TRIAL-EGYPT 219	100-TRIAL-Egypt 65	14 	818
64	8 	255-TRIAL-EL SALVADOR 24	281-TRIAL-El Salvador 264	19 	222
65	1 	280-TRIAL-EQUATORIAL GUINEA 106	76-TRIAL-Equatorial Guinea 186	84 	226
66	1 	35-TRIAL-ERITREA 32	25-TRIAL-Eritrea 125	13 	232
67	3 	102-TRIAL-ESTONIA 167	194-TRIAL-Estonia 247	27 	233
68	1 	166-TRIAL-ETHIOPIA 210	122-TRIAL-Ethiopia 159	22 	231
69	9 	46-TRIAL-FALKLAND ISLANDS (MALVINAS) 44	236-TRIAL-Falkland Islands (Malvinas) 199	9- 	238
70	2 	257-TRIAL-FAROE ISLANDS 5	197-TRIAL-Faroe Islands 131	27 	234
71	2 	31-TRIAL-FIJI 186	74-TRIAL-Fiji 292	26 	242
72	2 	51-TRIAL-FINLAND 83	178-TRIAL-Finland 218	22 	246
73	4 	252-TRIAL-FRANCE 116	234-TRIAL-France 46	16 	250
74	9 	7-TRIAL-FRENCH GUIANA 90	264-TRIAL-French Guiana 229	78 	254
75	1 	35-TRIAL-FRENCH POLYNESIA 30	291-TRIAL-French Polynesia 67	13 	258
76	8 	73-TRIAL-FRENCH SOUTHERN TERRITORIES 146	215-TRIAL-French Southern Territories 81	89 	\N
77	1 	73-TRIAL-GABON 255	66-TRIAL-Gabon 296	18 	266
78	5 	199-TRIAL-GAMBIA 43	15-TRIAL-Gambia 179	21 	270
79	6 	18-TRIAL-GEORGIA 176	219-TRIAL-Georgia 281	11 	268
80	1 	257-TRIAL-GERMANY 76	43-TRIAL-Germany 229	13 	276
81	3 	113-TRIAL-GHANA 7	279-TRIAL-Ghana 296	20 	288
82	1 	172-TRIAL-GIBRALTAR 204	158-TRIAL-Gibraltar 283	38 	292
83	1 	249-TRIAL-GREECE 77	80-TRIAL-Greece 82	26 	300
84	1 	90-TRIAL-GREENLAND 206	67-TRIAL-Greenland 249	57 	304
85	4 	236-TRIAL-GRENADA 270	78-TRIAL-Grenada 263	27 	308
86	8 	162-TRIAL-GUADELOUPE 93	153-TRIAL-Guadeloupe 14	85 	312
87	1 	23-TRIAL-GUAM 39	23-TRIAL-Guam 193	26 	316
88	2 	120-TRIAL-GUATEMALA 48	139-TRIAL-Guatemala 106	16 	320
89	1 	3-TRIAL-GUINEA 54	215-TRIAL-Guinea 93	22 	324
90	1 	130-TRIAL-GUINEA-BISSAU 47	148-TRIAL-Guinea-Bissau 291	98 	624
91	2 	132-TRIAL-GUYANA 180	176-TRIAL-Guyana 243	21 	328
92	1 	59-TRIAL-HAITI 230	34-TRIAL-Haiti 236	29 	332
93	1 	169-TRIAL-HEARD ISLAND AND MCDONALD ISLANDS 89	234-TRIAL-Heard Island and Mcdonald Islands 85	14 	\N
94	1 	167-TRIAL-HOLY SEE (VATICAN CITY STATE) 152	11-TRIAL-Holy See (Vatican City State) 168	2- 	336
95	8 	193-TRIAL-HONDURAS 38	195-TRIAL-Honduras 71	20 	340
96	1 	244-TRIAL-HONG KONG 29	246-TRIAL-Hong Kong 46	18 	344
97	1 	14-TRIAL-HUNGARY 117	163-TRIAL-Hungary 179	17 	348
98	2 	294-TRIAL-ICELAND 277	161-TRIAL-Iceland 209	29 	352
99	1 	21-TRIAL-INDIA 163	179-TRIAL-India 222	49 	356
100	7 	174-TRIAL-INDONESIA 203	289-TRIAL-Indonesia 289	44 	360
101	1 	219-TRIAL-IRAN, ISLAMIC REPUBLIC OF 32	213-TRIAL-Iran, Islamic Republic of 92	17 	364
102	2 	21-TRIAL-IRAQ 139	139-TRIAL-Iraq 19	25 	368
103	9 	56-TRIAL-IRELAND 22	58-TRIAL-Ireland 279	83 	372
104	3 	245-TRIAL-ISRAEL 162	28-TRIAL-Israel 88	28 	376
105	1 	54-TRIAL-ITALY 241	290-TRIAL-Italy 12	13 	380
106	1 	126-TRIAL-JAMAICA 36	105-TRIAL-Jamaica 110	27 	388
107	2 	203-TRIAL-JAPAN 130	38-TRIAL-Japan 203	29 	392
108	1 	46-TRIAL-JORDAN 196	219-TRIAL-Jordan 76	71 	400
109	2 	222-TRIAL-KAZAKHSTAN 167	276-TRIAL-Kazakhstan 134	25 	398
110	1 	113-TRIAL-KENYA 186	7-TRIAL-Kenya 33	26 	404
111	1 	225-TRIAL-KIRIBATI 253	252-TRIAL-Kiribati 262	22 	296
112	3 	60-TRIAL-KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF 11	166-TRIAL-Korea, Democratic People's Republic of 293	44 	408
113	1 	148-TRIAL-KOREA, REPUBLIC OF 284	116-TRIAL-Korea, Republic of 131	23 	410
114	8 	176-TRIAL-KUWAIT 284	208-TRIAL-Kuwait 249	16 	414
115	1 	182-TRIAL-KYRGYZSTAN 138	184-TRIAL-Kyrgyzstan 159	26 	417
116	1 	167-TRIAL-LAO PEOPLE'S DEMOCRATIC REPUBLIC 29	228-TRIAL-Lao People's Democratic Republic 118	56 	418
117	2 	226-TRIAL-LATVIA 147	33-TRIAL-Latvia 79	32 	428
118	3 	113-TRIAL-LEBANON 9	30-TRIAL-Lebanon 257	10 	422
119	1 	226-TRIAL-LESOTHO 281	169-TRIAL-Lesotho 179	19 	426
120	2 	40-TRIAL-LIBERIA 88	255-TRIAL-Liberia 71	70 	430
121	7 	203-TRIAL-LIBYAN ARAB JAMAHIRIYA 224	245-TRIAL-Libyan Arab Jamahiriya 129	24 	434
122	1 	207-TRIAL-LIECHTENSTEIN 91	11-TRIAL-Liechtenstein 98	18 	438
123	1 	110-TRIAL-LITHUANIA 126	33-TRIAL-Lithuania 109	22 	440
124	1 	13-TRIAL-LUXEMBOURG 7	141-TRIAL-Luxembourg 13	94 	442
125	7 	96-TRIAL-MACAO 271	114-TRIAL-Macao 5	34 	446
126	2 	179-TRIAL-MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF 41	44-TRIAL-Macedonia, the Former Yugoslav Republic of 119	24 	807
127	1 	141-TRIAL-MADAGASCAR 69	82-TRIAL-Madagascar 278	3- 	450
128	1 	285-TRIAL-MALAWI 122	75-TRIAL-Malawi 180	16 	454
129	1 	244-TRIAL-MALAYSIA 288	129-TRIAL-Malaysia 176	14 	458
130	2 	168-TRIAL-MALDIVES 119	41-TRIAL-Maldives 77	10 	462
131	1 	92-TRIAL-MALI 150	249-TRIAL-Mali 189	28 	466
132	2 	145-TRIAL-MALTA 17	60-TRIAL-Malta 147	16 	470
133	2 	83-TRIAL-MARSHALL ISLANDS 28	130-TRIAL-Marshall Islands 82	29 	584
134	1 	282-TRIAL-MARTINIQUE 133	166-TRIAL-Martinique 268	19 	474
135	5 	261-TRIAL-MAURITANIA 297	50-TRIAL-Mauritania 119	11 	478
136	8 	15-TRIAL-MAURITIUS 24	258-TRIAL-Mauritius 99	12 	480
137	7 	177-TRIAL-MAYOTTE 221	141-TRIAL-Mayotte 2	22 	\N
138	1 	53-TRIAL-MEXICO 107	206-TRIAL-Mexico 95	13 	484
139	6 	46-TRIAL-MICRONESIA, FEDERATED STATES OF 151	85-TRIAL-Micronesia, Federated States of 52	24 	583
140	4 	106-TRIAL-MOLDOVA, REPUBLIC OF 295	43-TRIAL-Moldova, Republic of 255	65 	498
141	2 	119-TRIAL-MONACO 16	42-TRIAL-Monaco 157	26 	492
142	1 	278-TRIAL-MONGOLIA 49	230-TRIAL-Mongolia 34	26 	496
143	1 	203-TRIAL-MONTSERRAT 98	277-TRIAL-Montserrat 47	25 	500
144	2 	231-TRIAL-MOROCCO 258	216-TRIAL-Morocco 284	26 	504
145	1 	28-TRIAL-MOZAMBIQUE 46	196-TRIAL-Mozambique 10	96 	508
146	2 	112-TRIAL-MYANMAR 47	66-TRIAL-Myanmar 39	18 	104
147	2 	147-TRIAL-NAMIBIA 47	135-TRIAL-Namibia 36	68 	516
148	1 	156-TRIAL-NAURU 61	193-TRIAL-Nauru 122	75 	520
149	1 	20-TRIAL-NEPAL 189	292-TRIAL-Nepal 30	29 	524
150	1 	140-TRIAL-NETHERLANDS 173	122-TRIAL-Netherlands 231	82 	528
151	1 	258-TRIAL-NETHERLANDS ANTILLES 219	155-TRIAL-Netherlands Antilles 124	34 	530
152	1 	84-TRIAL-NEW CALEDONIA 0	146-TRIAL-New Caledonia 148	3- 	540
153	1 	72-TRIAL-NEW ZEALAND 174	134-TRIAL-New Zealand 92	11 	554
154	5 	109-TRIAL-NICARAGUA 47	130-TRIAL-Nicaragua 213	11 	558
155	2 	244-TRIAL-NIGER 216	185-TRIAL-Niger 27	23 	562
156	1 	4-TRIAL-NIGERIA 287	267-TRIAL-Nigeria 15	22 	566
157	2 	87-TRIAL-NIUE 14	146-TRIAL-Niue 149	18 	570
158	9 	91-TRIAL-NORFOLK ISLAND 106	142-TRIAL-Norfolk Island 123	17 	574
159	7 	206-TRIAL-NORTHERN MARIANA ISLANDS 24	93-TRIAL-Northern Mariana Islands 96	27 	580
160	2 	42-TRIAL-NORWAY 83	263-TRIAL-Norway 282	43 	578
161	2 	197-TRIAL-OMAN 168	240-TRIAL-Oman 257	20 	512
162	1 	222-TRIAL-PAKISTAN 100	25-TRIAL-Pakistan 41	44 	586
163	2 	74-TRIAL-PALAU 278	67-TRIAL-Palau 160	19 	585
164	1 	277-TRIAL-PALESTINIAN TERRITORY, OCCUPIED 194	68-TRIAL-Palestinian Territory, Occupied 249	22 	\N
165	1 	67-TRIAL-PANAMA 43	47-TRIAL-Panama 15	24 	591
166	1 	267-TRIAL-PAPUA NEW GUINEA 230	172-TRIAL-Papua New Guinea 56	22 	598
167	1 	243-TRIAL-PARAGUAY 193	246-TRIAL-Paraguay 123	77 	600
168	3 	157-TRIAL-PERU 282	96-TRIAL-Peru 262	16 	604
169	1 	148-TRIAL-PHILIPPINES 1	284-TRIAL-Philippines 28	41 	608
170	2 	217-TRIAL-PITCAIRN 245	27-TRIAL-Pitcairn 196	13 	612
171	9 	294-TRIAL-POLAND 171	27-TRIAL-Poland 292	24 	616
172	2 	219-TRIAL-PORTUGAL 85	252-TRIAL-Portugal 31	36 	620
173	4 	260-TRIAL-PUERTO RICO 113	255-TRIAL-Puerto Rico 75	12 	630
174	2 	60-TRIAL-QATAR 12	50-TRIAL-Qatar 128	12 	634
175	2 	13-TRIAL-REUNION 91	122-TRIAL-Reunion 151	21 	638
176	2 	230-TRIAL-ROMANIA 161	91-TRIAL-Romania 148	17 	642
177	2 	179-TRIAL-RUSSIAN FEDERATION 203	252-TRIAL-Russian Federation 245	28 	643
178	1 	109-TRIAL-RWANDA 242	160-TRIAL-Rwanda 196	28 	646
179	9 	39-TRIAL-SAINT HELENA 253	267-TRIAL-Saint Helena 189	16 	654
180	3 	254-TRIAL-SAINT KITTS AND NEVIS 81	91-TRIAL-Saint Kitts and Nevis 42	24 	659
181	7 	182-TRIAL-SAINT LUCIA 107	83-TRIAL-Saint Lucia 197	96 	662
182	2 	207-TRIAL-SAINT PIERRE AND MIQUELON 133	259-TRIAL-Saint Pierre and Miquelon 86	15 	666
183	1 	245-TRIAL-SAINT VINCENT AND THE GRENADINES 233	246-TRIAL-Saint Vincent and the Grenadines 274	29 	670
184	1 	148-TRIAL-SAMOA 232	146-TRIAL-Samoa 117	89 	882
185	1 	268-TRIAL-SAN MARINO 81	148-TRIAL-San Marino 200	18 	674
186	2 	126-TRIAL-SAO TOME AND PRINCIPE 64	169-TRIAL-Sao Tome and Principe 252	20 	678
187	2 	130-TRIAL-SAUDI ARABIA 95	66-TRIAL-Saudi Arabia 241	17 	682
188	2 	294-TRIAL-SENEGAL 184	173-TRIAL-Senegal 184	20 	686
189	2 	134-TRIAL-SERBIA AND MONTENEGRO 161	226-TRIAL-Serbia and Montenegro 230	11 	\N
190	8 	98-TRIAL-SEYCHELLES 194	199-TRIAL-Seychelles 26	27 	690
191	1 	118-TRIAL-SIERRA LEONE 283	56-TRIAL-Sierra Leone 71	10 	694
192	7 	243-TRIAL-SINGAPORE 224	108-TRIAL-Singapore 227	23 	702
193	2 	71-TRIAL-SLOVAKIA 231	90-TRIAL-Slovakia 134	16 	703
194	7 	284-TRIAL-SLOVENIA 69	145-TRIAL-Slovenia 181	92 	705
195	2 	1-TRIAL-SOLOMON ISLANDS 121	60-TRIAL-Solomon Islands 283	11 	90
196	2 	232-TRIAL-SOMALIA 284	71-TRIAL-Somalia 8	20 	706
197	7 	299-TRIAL-SOUTH AFRICA 159	160-TRIAL-South Africa 137	18 	710
198	1 	239-TRIAL-SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS 212	55-TRIAL-South Georgia and the South Sandwich Islands 297	17 	\N
199	5 	128-TRIAL-SPAIN 253	10-TRIAL-Spain 138	39 	724
200	2 	267-TRIAL-SRI LANKA 48	105-TRIAL-Sri Lanka 56	0- 	144
201	2 	162-TRIAL-SUDAN 29	16-TRIAL-Sudan 170	72 	736
202	2 	280-TRIAL-SURINAME 299	64-TRIAL-Suriname 125	17 	740
203	2 	242-TRIAL-SVALBARD AND JAN MAYEN 204	62-TRIAL-Svalbard and Jan Mayen 36	14 	744
204	7 	143-TRIAL-SWAZILAND 16	140-TRIAL-Swaziland 82	42 	748
205	1 	173-TRIAL-SWEDEN 238	49-TRIAL-Sweden 269	79 	752
206	2 	186-TRIAL-SWITZERLAND 86	261-TRIAL-Switzerland 93	25 	756
207	2 	152-TRIAL-SYRIAN ARAB REPUBLIC 244	51-TRIAL-Syrian Arab Republic 152	11 	760
208	1 	89-TRIAL-TAIWAN, PROVINCE OF CHINA 100	54-TRIAL-Taiwan, Province of China 196	51 	158
209	2 	267-TRIAL-TAJIKISTAN 168	45-TRIAL-Tajikistan 16	25 	762
210	1 	61-TRIAL-TANZANIA, UNITED REPUBLIC OF 214	154-TRIAL-Tanzania, United Republic of 270	29 	834
211	7 	56-TRIAL-THAILAND 30	271-TRIAL-Thailand 234	15 	764
212	1 	123-TRIAL-TIMOR-LESTE 100	116-TRIAL-Timor-Leste 190	22 	\N
213	1 	8-TRIAL-TOGO 48	202-TRIAL-Togo 61	24 	768
214	2 	209-TRIAL-TOKELAU 201	103-TRIAL-Tokelau 64	21 	772
215	2 	152-TRIAL-TONGA 35	200-TRIAL-Tonga 108	26 	776
216	2 	127-TRIAL-TRINIDAD AND TOBAGO 60	82-TRIAL-Trinidad and Tobago 57	29 	780
217	3 	225-TRIAL-TUNISIA 91	113-TRIAL-Tunisia 96	11 	788
218	1 	291-TRIAL-TURKEY 84	256-TRIAL-T├╝rkiye 159	21 	792
219	2 	264-TRIAL-TURKMENISTAN 209	171-TRIAL-Turkmenistan 67	25 	795
220	8 	113-TRIAL-TURKS AND CAICOS ISLANDS 9	123-TRIAL-Turks and Caicos Islands 1	24 	796
221	2 	37-TRIAL-TUVALU 191	182-TRIAL-Tuvalu 190	26 	798
222	3 	98-TRIAL-UGANDA 19	113-TRIAL-Uganda 74	29 	800
223	2 	74-TRIAL-UKRAINE 190	99-TRIAL-Ukraine 118	14 	804
224	4 	116-TRIAL-UNITED ARAB EMIRATES 257	37-TRIAL-United Arab Emirates 165	17 	784
225	1 	60-TRIAL-UNITED KINGDOM 26	40-TRIAL-United Kingdom 119	22 	826
226	1 	250-TRIAL-UNITED STATES 39	229-TRIAL-United States 209	14 	840
227	4 	0-TRIAL-UNITED STATES MINOR OUTLYING ISLANDS 129	58-TRIAL-United States Minor Outlying Islands 202	10 	\N
228	6 	72-TRIAL-URUGUAY 229	34-TRIAL-Uruguay 266	15 	858
229	5 	75-TRIAL-UZBEKISTAN 87	201-TRIAL-Uzbekistan 294	11 	860
230	2 	28-TRIAL-VANUATU 226	9-TRIAL-Vanuatu 101	55 	548
231	2 	113-TRIAL-VENEZUELA 25	138-TRIAL-Venezuela 42	26 	862
232	2 	241-TRIAL-VIET NAM 234	115-TRIAL-Viet Nam 95	13 	704
233	7 	117-TRIAL-VIRGIN ISLANDS, BRITISH 249	63-TRIAL-Virgin Islands, British 140	21 	92
234	2 	71-TRIAL-VIRGIN ISLANDS, U.S. 282	49-TRIAL-Virgin Islands, U.s. 262	16 	850
235	1 	86-TRIAL-WALLIS AND FUTUNA 28	16-TRIAL-Wallis and Futuna 196	11 	876
236	1 	212-TRIAL-WESTERN SAHARA 30	68-TRIAL-Western Sahara 53	48 	732
237	0 	54-TRIAL-YEMEN 170	151-TRIAL-Yemen 152	26 	887
238	1 	251-TRIAL-ZAMBIA 121	93-TRIAL-Zambia 243	35 	894
239	1 	282-TRIAL-ZIMBABWE 269	124-TRIAL-Zimbabwe 128	28 	716
\.


--
-- Data for Name: t_cp_allocation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cp_allocation (id, prcss_id, flow_id, flow_type_id, amount, unit_amount, allocation_amount, cost, unit_cost, allocation_cost, env_impact, unit_env_impact, allocation_env_impact, reference, unit_reference, kpi, unit_kpi, kpi_error, benchmark_kpi, best_practice, capexold, ltold, capexnew, ltnew, newcons, disrate, marcos, ecoben, error_cost, error_amount, error_ep, option, nameofref, kpidef, opexold, opexnew, anncostold, anncostnew, ecocosben, unit1, oldtotalcons, oldtotalcost, oldtotalep, unit2, ecobenunit, marcosunit, description) FROM stdin;
45	82	69	2	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	1		200.00	300.00	400.00	50.00	15000.00	10.00	66.77	-19500.00	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	77	60	2	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
50	86	74	1	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	0.400000000000000022		\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
56	102	5	1	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	22.00	33	22	\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
48	84	1	1	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	20.00	1	option	\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
49	83	5	1	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	1	option 2	\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
28	76	60	2	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	20.00	123		6000.00	50.00	3000.00	60.00	50000.00	10.00	219.16	-36000.00	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
33	78	60	2	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	900		\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	77	60	2	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	0.00	1230		500.00	30.00	600.00	25.00	1600.00	5.00	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	76	60	1	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	1200	0.9	2000.00	10.00	3000.00	20.00	600.00	5.00	-220.14	13400.00	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
32	78	60	1	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	0.00	400		2000.00	30.00	3000.00	30.00	2000.00	15.00	245.38	-600.00	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	77	61	2	1000.00	kg	20.00	500.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	kg/year	10.00	3000		\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
68	90	2	1	20000.00	kWh	80.00	2000.00	TL	80.00	14320000.00	EP	80	20.000	kg	1000	kWh/kg	\N	600	efficency electric drive	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
103	91	2	1	500.00	kWh	10.00	50.00	Euro	10.00	4000.00	EP	90	1.000	hours/year	500	kWh/hours/year	\N	500	ccc	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
69	91	2	1	10000.00	kWh	20.00	2000.00	Euro	20.00	14320000.00	EP	20	1000.000	m┬▓	10	kWh/m┬▓	\N	500	ccc	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
67	90	60	1	10000.00	kg	50.00	20000.00	Euro	50.00	107000000.00	EP	50	2000.000	kg	5	kg/kg	\N	4	Change raw material size	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
104	98	90	1	150000.00	kg	100.00	5000.00	Euro	100.00	100000.00	EP	50	100000.000	kWh	2	kg/kWh	\N	10	stoind	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
105	97	89	1	100000.00	kg	100.00	150.00	Dolar	100.00	21.00	EP	100	140000.000	kg	1	kg/kg	\N	2	dfg	\N	\N	\N	\N	\N	\N	\N	\N	100	100	70	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
102	95	1	1	500.00	kg	30.00	440.00	Euro	30.00	4400.00	EP	30	91000.000	kg	0.00549000000000000009	kg/kg	\N	0.00100000000000000002	dlfkjgklfjg	\N	\N	\N	\N	\N	\N	\N	\N	60	60	60	1			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
106	97	86	1	65000.00	kg	100.00	650.00	Euro	100.00	30.00	EP	100	14000.000	kg	4.64285999999999976	kg/kg	\N	4		\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	sdfsdff		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
107	92	84	1	26000.00	kg	80.00	26000.00	Euro	80.00	260.00	EP	80	200.000	kWh	130	kg/kWh	\N	130		\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
66	79	1	1	1000.00	Liter	70.00	1200.00	Euro	70.00	1000000.00	EP	70	1.000	year	1000	Liter/year	\N	1000	best practice 1	\N	\N	\N	\N	\N	\N	\N	\N	95	90	90	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
39	80	2	1	1000.00	KW	20.00	800.00	Euro	30.00	1000000.00	EP	30	1.000	year	1000	KW/year	100.00	1200	negative is good	20000.00	11.50	90000.00	4.50	10000.00	5.00	0.73	750000.00	90	90	95	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
58	88	1	1	1000.00	Liter	20.00	500.00	Euro	30.00	2000000.00	EP	30	1.000	year	1000	Liter/year	\N	500	Tuna Practice	20000.00	10.00	10000.00	4.50	20000.00	5.00	-0.18	1000000.00	90	90	95	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
75	96	85	2	100000.00	kg	100.00	10000000.00	Euro	100.00	100000.00	EP	100	126120.000	kg	0.792900000000000049	kg/kg	\N	2	ldkjfgklfdj	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	printed paper	paper / printed paper	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
125	150	24	1	10000.00	kg	100.00	-1000.00	Euro	100.00	1000000.00	EP	100	1000.000	kWh	10	kg/kWh	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	amount per electricty		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
84	113	60	2	2800.00	kg	100.00	7700.00	TL	100.00	280.00	EP	100	190595.000	%	0.0146899999999999999	kg/%	\N	2.10000000000000009	optimization / change of raw material size / convert to energy efficient CNCs	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
87	118	104	1	12.00	unit	100.00	780.00	TL	100.00	21.72	EP	100	5200.000	kg	0.00230999999999999999	unit/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
88	113	108	2	1000.00	kg	100.00	2500.00	TL	100.00	323.00	EP	100	20800.000	kg	0.0480799999999999977	kg/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
91	114	117	1	1.85	m┬│	100.00	16605.00	TL	100.00	1726.00	EP	100	1.000	year	1.84499999999999997	m┬│/year	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
90	119	114	2	1.00	kg	100.00	500.00	TL	100.00	2.50	EP	100	5000.000	kg	0.00020000000000000001	kg/kg	\N	0.00220000000000000013	buy a cleaner machine	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
79	113	112	1	1000.00	kg	100.00	3500.00	TL	100.00	905.00	EP	100	200.000	kg	5	kg/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
92	113	103	1	30750.00	Liter	100.00	16906.00	TL	100.00	138.99	EP	100	5200.000	kg	5.91345999999999972	Liter/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
94	113	109	1	350.00	unit	100.00	180000.00	TL	100.00	462.00	EP	100	5200.000	kg	0.0673099999999999948	unit/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	90	100	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
97	116	105	1	13861.00	kWh	3.00	3327.00	TL	3.00	9331.00	EP	3	500.000	m┬▓	27.7220000000000013	kWh/m┬▓	\N	43	change to gas heating, use termostats for automatic control of temperature, keep windows closed, improve isolation of the windows	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
98	123	105	1	50825.00	kWh	11.00	12198.00	TL	11.00	34157.00	EP	11	4000.000	m┬▓	12.7062500000000007	kWh/m┬▓	\N	28	Use led systems	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
99	122	105	1	18481.92	kWh	4.00	4435.00	TL	4.00	9008.00	EP	4	18481.920	kWh	1	kWh/kWh	\N	0.5	Closing the leaks, optimise the pressure/running time without load, use electric with frequency converters	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	1			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
100	119	105	1	4620.00	kWh	1.00	1109.00	TL	1.00	3021.00	EP	1	462048.000	kWh	0.0100000000000000002	kWh/kWh	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
118	119	69	2	326.00	m┬│	100.00	6000.00	TL	100.00	105.00	EP	100	1260.000	m┬│	0.258730000000000016	m┬│/m┬│	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
89	119	114	1	6.00	kg	100.00	600.00	TL	100.00	11.64	EP	100	5000.000	kg	0.00119999999999999989	kg/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
80	113	112	2	200.00	kg	90.00	200.00	TL	100.00	20.00	EP	100	200.000	kg	1	kg/kg	\N	0.900000000000000022	optimization / change of raw material size / convert to energy efficient CNCs	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
83	113	60	1	14000.00	kg	100.00	30800.00	TL	100.00	65660.00	EP	100	2800.000	kg	5	kg/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
108	97	2	1	3000000.00	kWh	80.00	3000000.00	Euro	80.00	30.00	EP	80	15000000.000	kg	0.200000000000000011	kWh/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Tste		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
115	108	4	1	45.00	%	12.00	6788888.00	Dolar	45.00	11.00	EP	11	333333333333333.000	Amper	0	%/Amper	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	23	23	11	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
101	94	1	1	1000.00	kg	70.00	1000.00	Euro	70.00	10000.00	EP	70	26000.000	kg	0.0384600000000000011	kg/kg	\N	0.0449999999999999983	ldfkjgklfgsddf	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	├Âsdkf├Âdslf	lsdjf/skdfh	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
120	140	146	1	83500.00	Liter	100.00	8400.00	Euro	100.00	0.08	EP	100	10721.000	m┬▓	7.7884500000000001	Liter/m┬▓	\N	4.29999999999999982		\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Heated area	Fuel oil / heated area	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
126	153	2	1	8000.00	kWh	100.00	800.00	CHF	100.00	4000.00	EP	100	8000.000	m┬│	1	kWh/m┬│	\N	0.5	Improved compressed air	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	generated air volume		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
129	152	2	1	2000.00	kWh	100.00	200.00	CHF	100.00	1000.00	EP	100	20.000	year	100	kWh/year	\N	50	el savving by improved washing	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	pumping el for water	annual pumping energy	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
130	154	5	1	5000.00	kg	100.00	1000.00	CHF	100.00	1000.00	EP	100	400.000	pieces/year	12.5	kg/pieces/year	\N	14	vvvv	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	gggg		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
132	155	2	1	100.00	kWh	100.00	100.00	CHF	100.00	30.00	EP	100	10000000.000	pieces/year	1.00000000000000008e-05	kWh/pieces/year	\N	2.00000000000000016e-05	cccc	\N	\N	\N	\N	\N	\N	\N	\N	50	50	60	1	number of bottles		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
77	113	66	2	2100.00	kg	100.00	25200.00	TL	100.00	1050.00	EP	100	142080.000	kWh	0.0147799999999999997	kg/kWh	\N	2.79999999999999982	optimization / change of raw material size / convert to energy efficient CNCs	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	1			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
81	113	61	1	400.00	kg	100.00	21600.00	TL	100.00	2464.00	EP	100	100.000	kg	4	kg/kg	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
93	114	103	2	27675.00	Liter	100.00	10000.00	TL	100.00	125.00	EP	100	5123.000	kg	5.40211000000000041	Liter/kg	\N	0.0599999999999999978	minimize lubrication / dry cutting and minimum quantity lubrication	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
96	113	105	1	346536.00	kWh	75.00	83168.00	TL	75.00	232872.00	EP	75	5200.000	kg	66.6415400000000062	kWh/kg	\N	0.699999999999999956	optimization / size of raw materila changing / Energry efficient CNC	\N	\N	\N	\N	\N	\N	\N	\N	60	60	60	0			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
82	113	61	2	23.00	kg	100.00	3672.00	TL	100.00	2.30	EP	100	500.000	kg	0.0459999999999999992	kg/kg	\N	1	optimization / change of raw material size / convert to energy efficient CNCs	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
140	160	66	1	12.00	1/seconed	12.00	12.00	Dollar	12.00	12.00	EP	12	2.000	1/seconed	6	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ee	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
85	113	107	2	100.00	m┬│	100.00	1500.00	TL	100.00	590.00	EP	100	1.000	year	100	m┬│/year	\N	91.1234500000000054		\N	\N	\N	\N	\N	\N	\N	\N	90	90	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
117	113	66	1	10500.00	kg	100.00	126000.00	TL	100.00	80850.00	EP	100	4200.000	pieces/year	2.5	kg/pieces/year	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0		Aluminium/pieces	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
142	162	114	2	12.00	1/seconed	12.00	12.00	Dollar	12.00	12.00	EP	12	12.000	1/seconed	1	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ee	ww	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
119	119	1	1	1260.00	m┬│	100.00	13104.00	TL	100.00	0.10	EP	100	1700.000	m┬▓	0.74117999999999995	m┬│/m┬▓	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
141	122	105	1	12.00	1/seconed	12.00	12.00	Dollar	12.00	12.00	EP	12	2.000	1/seconed	6	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ee	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
143	161	66	2	12.00	1/seconed	12.00	12.00	Dollar	12.00	12.00	EP	12	12.000	1/seconed	1	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ee	ww	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
86	116	98	1	12000.00	m┬│	100.00	15000.00	TL	100.00	28080.00	EP	100	1200.000	m┬▓	10	m┬│/m┬▓	\N	4.29999999999999982	reuse of waste heat / improvement of the burner / low temperature heating system / condensing technology	\N	\N	\N	\N	\N	\N	\N	\N	100	100	50	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
121	141	105	1	1000.00	kWh	1.00	250.00	TL	1.00	654.00	EP	1	1000.000	kWh	1	kWh/kWh	\N	0.5	intergration of a heat exchanger in ventialtion	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
144	163	114	1	12.00	1/seconed	12.00	12.00	Dollar	12.00	12.00	EP	12	12.000	1/seconed	1	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ww	ee	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
145	122	66	1	12.00	1/seconed	12.00	12.00	Dollar	12.00	12.00	EP	12	12.000	1/seconed	1	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ww	ee	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
146	164	114	1	12.00	1/seconed	12.00	12.00	TL	12.00	12.00	EP	12	12.000	%	1	1/seconed/%	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ee	er	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
147	165	66	1	12.00	1/seconed	12.00	12.00	TL	12.00	12.00	EP	12	12.000	%	1	1/seconed/%	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ww	rt	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
148	166	103	1	12.00	1/seconed	12.00	12.00	TL	12.00	12.00	EP	12	12.000	1/seconed	1	1/seconed/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	12	12	12	1	ee	rr	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
150	159	2	1	6900000.00	kWh	100.00	800000.00	CHF	100.00	1800000.00	EP	100	12181000.000	kg	0.566459999999999964	kWh/kg	\N	0.800000000000000044	Dummy Benchmark	\N	\N	\N	\N	\N	\N	\N	\N	95	95	90	0	Windows produced	electrcityper glass	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
151	168	132	1	38624.00	kg	100.00	700000.00	CHF	100.00	610.30	EP	100	38624.000	kg	1	kg/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	95	95	90	1	dummy		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
154	171	89	2	431.50	to (tons)	100.00	-26000.00	CHF	100.00	1600.00	EP	100	13950.000	to (tons)	0.0309299999999999992	to (tons)/to (tons)	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	75	90	90	1	product	share wastepaper	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
161	128	86	1	284.00	to (tons)	100.00	1000000.00	CHF	100.00	903.12	EP	100	13950.000	to (tons)	0.0203599999999999996	to (tons)/to (tons)	\N	0.0200000000000000004	no	\N	\N	\N	\N	\N	\N	\N	\N	95	95	80	1	product	color per product	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
159	172	190	2	11000.00	kg	100.00	4500.00	CHF	100.00	2.70	EP	100	1.000	year	11000	kg/year	\N	3300	dewatering spent cutting fluid to 30%	\N	\N	\N	\N	\N	\N	\N	\N	80	95	80	1	year	Annual spent cutting fluid	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
139	158	2	1	885545.00	kWh	100.00	123000.00	CHF	100.00	246.00	EP	100	885545.000	year	1	kWh/year	\N	1	Eco electrcity St.Gallen	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	non renewable consumption per year	electrcity	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
112	135	133	2	38624.00	kg	100.00	-35000.00	CHF	100.00	21.80	EP	100	38624.000	kg	1	kg/kg	\N	1		\N	\N	\N	\N	\N	\N	\N	\N	50	95	50	1			\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
156	173	103	1	1200.00	Liter	100.00	9960.00	CHF	100.00	2.50	EP	100	1.000	year	1200	Liter/year	\N	392	High pressure jet-assisted machining	\N	\N	\N	\N	\N	\N	\N	\N	95	95	90	1	period	annual concentrated cutting fluid consumption	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
110	130	98	1	640000.00	kWh	100.00	70400.00	CHF	100.00	120.00	EP	100	9000.000	m┬▓	71.1111099999999965	kWh/m┬▓	\N	50	Disctrict heating	\N	\N	\N	\N	\N	\N	\N	\N	95	95	80	1	heated area	specific heating energy	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
160	128	85	1	14381.00	to (tons)	100.00	9347650.00	CHF	100.00	22578.17	EP	100	1.000	year	14381	to (tons)/year	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	95	95	80	1	year	paper consumption	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
158	173	2	1	35000.00	kWh	5.00	4900.00	CHF	5.00	9.37	EP	5	1.000	year	35000	kWh/year	\N	35000	HPJ requires compressed air	\N	\N	\N	\N	\N	\N	\N	\N	50	50	50	0	year	estimated pump energy	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
152	128	2	1	2900000.00	kWh	100.00	367720.00	CHF	100.00	88.70	EP	100	13950.000	to (tons)	207.885300000000001	kWh/to (tons)	\N	670		\N	\N	\N	\N	\N	\N	\N	\N	90	90	80	0	product	electrcity cons. per product	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
162	174	2	1	6900000.00	kWh	100.00	800000.00	CHF	100.00	2084.00	EP	100	12000.000	to (tons)	575	kWh/to (tons)	\N	600	dummy Benchmark	\N	\N	\N	\N	\N	\N	\N	\N	95	95	80	0	product	spec electricty consumption	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
179	192	196	2	1500.00	to (tons)	100.00	100.00	CHF	100.00	1575.00	EP	100	11044.000	to (tons)	0.135819999999999996	to (tons)/to (tons)	\N	0.100000000000000006	dummy	\N	\N	\N	\N	\N	\N	\N	\N	90	90	80	1	flatglass input	losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
180	192	200	2	3000.00	to (tons)	100.00	100.00	CHF	100.00	6000.00	EP	100	15900.000	to (tons)	0.188679999999999987	to (tons)/to (tons)	\N	0.119999999999999996	dummy	\N	\N	\N	\N	\N	\N	\N	\N	90	80	80	1	saftey glass input	losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
181	189	199	2	40.00	to (tons)	100.00	12000.00	CHF	100.00	127.00	EP	100	192.000	to (tons)	0.208329999999999987	to (tons)/to (tons)	\N	0.149999999999999994	dummy	\N	\N	\N	\N	\N	\N	\N	\N	80	80	60	1	spacer input	losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
182	194	8	1	17432.00	to (tons)	100.00	5000.00	Euro	100.00	38890792.00	EP	100	6226.000	to (tons)	2.79986999999999986	to (tons)/to (tons)	\N	2	capsulation of reactor	\N	\N	\N	\N	\N	\N	\N	\N	90	90	80	1	Acetate yarn	specific acetone consumption	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
165	176	66	1	10500.00	kg	100.00	126000.00	TL	100.00	80850.00	EP	100	1.000	1/seconed	10500	kg/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	s	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
166	177	66	1	10500.00	kg	100.00	126000.00	TL	100.00	80850.00	EP	100	1.000	1/seconed	10500	kg/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	1		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
167	178	103	1	30750.00	Liter	100.00	16906.00	TL	100.00	138.99	EP	100	1.000	1/seconed	30750	Liter/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
168	179	107	2	100.00	m┬│	100.00	1500.00	TL	100.00	590.00	EP	100	1.000	1/seconed	100	m┬│/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	e	e	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
169	165	114	1	6.00	kg	100.00	600.00	TL	100.00	11.64	EP	100	1.000	dk	1	kg/dk	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
170	163	61	1	400.00	kg	100.00	21600.00	TL	100.00	2464.00	EP	100	1.000	1/seconed	1	kg/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
171	180	114	1	6.00	kg	100.00	600.00	TL	100.00	11.64	EP	100	1.000	1/seconed	6	kg/1/seconed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
172	181	66	1	10500.00	kg	100.00	126000.00	TL	100.00	80850.00	EP	100	1.000	Amper	10500	kg/Amper	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
173	182	114	1	6.00	kg	100.00	600.00	TL	100.00	11.64	EP	100	1.000	GJ (Gigajoule)	6	kg/GJ (Gigajoule)	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	1	1	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
174	183	66	1	10500.00	kg	100.00	126000.00	TL	100.00	80850.00	EP	100	1.000	degree	10500	kg/degree	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
175	184	103	2	55350.00	Liter	200.00	10000.00	TL	100.00	125.00	EP	100	1.000	bar	55350	Liter/bar	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	200	200	300	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
176	185	105	1	2772288.00	kWh	600.00	665346.00	TL	600.00	1813074.00	EP	600	1.000	degree	462048	kWh/degree	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	500	500	500	1	w	w	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
177	186	109	1	1750.00	unit	500.00	900000.00	TL	500.00	2310.00	EP	500	1.000	degree	1750	unit/degree	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	899	899	899	1	e	e	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
178	187	105	1	2772288.00	kWh	600.00	665346.00	TL	600.00	1813074.00	EP	600	34.000	Amper	81537.8823499999999	kWh/Amper	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	234	234	234	1	e	e	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
183	194	2	1	5187800.00	kWh	100.00	100000.00	Euro	100.00	581034.00	EP	100	6226.000	to (tons)	833.247669999999971	kWh/to (tons)	\N	1000	value	\N	\N	\N	\N	\N	\N	\N	\N	90	90	95	0	acetone yarn	specific electricity consumption for dissolving	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
157	173	1	1	11.00	m┬│	1.00	45.00	CHF	1.00	0.01	EP	1	1200.000	Liter	0.00916999999999999933	m┬│/Liter	\N	0		\N	\N	\N	\N	\N	\N	\N	\N	90	90	80	0	cuttingfluid	Dilution cuttingfluid with water	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
202	256	238	1	327.72	MWh	12.00	12240.00	CHF	12.00	44.60	EP	12	1690000.000	l	0.00019000000000000001	MWh/l	\N	0.000100000000000000005	cold disinfection	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	volume	specific_heat	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
471	380	306	1	30.00	kg	100.00	200000.00	CHF	100.00	0.03	EP	100	10000.000	kWh	0.00300000000000000006	kg/kWh	\N	0	xxxxx	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	annual energy production	fuel/power	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	xxxx
184	207	99	2	9600.00	GJ (Gigajoule)	80.00	50000.00	CHF	100.00	3000000.00	EP	100	8000.000	GJ (Gigajoule)	1.19999999999999996	GJ (Gigajoule)/GJ (Gigajoule)	\N	1.10000000000000009	this pasteurising	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	Test ref	test	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
187	208	1	1	5000000.00	Liter	100.00	33000.00	CHF	100.00	121111.00	EP	100	1.200	year	4166666.66667000018	Liter/year	\N	4000000	blobbad	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	year	estimated water usage	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
194	212	224	1	2700000.00	kg	4.31	2538.59	CHF	4.31	10133100.00	EP	4.29	10000000.000	kg	0.270000000000000018	kg/kg	\N	0.200000000000000011		\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	rawmilk	Water consumption CIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	See option cold sterilisation
198	228	228	2	30000.00	kg	100.00	-1200.00	CHF	100.00	105852616.00	EP	100	1000000.000	kg	0.0299999999999999989	kg/kg	\N	0.0200000000000000004	Improved set up printing machine	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Paper	Paper losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	AWDAWDW\n\nWDAW\nD\nAW\nD\nAWD\nW
334	290	267	1	4860000.00	kg	100.00	486000.00	CHF	100.00	10011600000.00	EP	100	901125.000	kg	5.39325999999999972	kg/kg	\N	5	Clinker production, 32% RDF, NOx treatment	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	NOx removed		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 3:\n67% petcoke and NOx reduction measures (no dust measures)
351	299	273	1	2048250.00	MJ	75.00	76500.00	CHF	75.00	51431557.50	EP	75	25000000.000	kg	0.0819300000000000028	MJ/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Raw Milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
214	257	241	1	300000.00	l	100.00	30000.00	CHF	100.00	1056600.00	EP	100	1690000.000	l	0.177510000000000001	l/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	volume	specific_rawmilk_feeding	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
203	256	240	1	88.20	MWh	4.90	11564.00	CHF	4.90	44.96	EP	4.9	1690000.000	l	5.00000000000000024e-05	MWh/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	volume	specific_electricity	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
211	253	221	1	1000.00	kg	100.00	3500.00	CHF	100.00	5945.00	EP	100	1690000.000	l	0.00059000000000000003	kg/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	volume	specific_phosphor	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
209	253	240	1	1677.60	MWh	93.20	219952.00	CHF	93.20	855.24	EP	93.2	1690000.000	l	0.000989999999999999995	MWh/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	volume	specific_electricity	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
208	253	224	1	62600.00	m┬│	100.00	106420.00	CHF	100.00	234.94	EP	100	1690000.000	l	0.0370399999999999965	m┬│/l	\N	0.299999999999999989	test	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	volume	specific_water_use	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
212	253	222	1	1000.00	kg	100.00	3500.00	CHF	100.00	1583.00	EP	100	1690000.000	l	0.00059000000000000003	kg/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	volume	specific_sodiumhydroxide	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
210	253	241	1	9940000.00	kg	99.40	4970000.00	CHF	99.40	35008680.00	EP	99.4	1690000.000	l	5.88166000000000011	kg/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	volume	specific_rawmilk_use	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
207	253	238	1	355.03	MWh	13.00	13260.00	CHF	13.00	48.32	EP	13	1690000.000	l	0.000210000000000000009	MWh/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	volume	specific_heat	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
205	255	241	2	3480.00	kg	0.60	1740.00	CHF	0.60	12256.56	EP	0.6	1690000.000	l	0.0020600000000000002	kg/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	volume	specific_loss	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
206	255	240	1	34.20	MWh	1.90	4484.00	CHF	1.90	17.44	EP	1.9	1690000.000	l	2.00000000000000016e-05	MWh/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	volume	specific_electricity	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
353	301	272	1	54000.00	kWh	3.00	70800.00	CHF	3.00	12605220.00	EP	3	10000000.000	kg	0.00540000000000000029	kWh/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Raw Milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
213	253	69	2	62600.00	m┬│	100.00	0.00	CHF	100.00	27.92	EP	100	1690000.000	l	0.0370399999999999965	m┬│/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	volume	specific_wastewater	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
204	254	238	1	2048.25	MWh	75.00	76500.00	CHF	75.00	278.77	EP	75	1690000.000	l	0.00120999999999999992	MWh/l	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	volume	specific_heat	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
217	258	238	1	8274.00	kWh	0.60	309.00	CHF	0.60	51.12	EP	.6	1690000.000	kg	0.00489999999999999984	kWh/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
220	262	224	1	450.00	m┬│	0.72	765.00	CHF	0.72	234.94	EP	100	10000000.000	kg	5.00000000000000024e-05	m┬│/kg	\N	0.200000000000000011	cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
218	258	240	1	11362.00	kWh	0.60	424.00	CHF	0.60	917.64	EP	100	1690000.000	kg	0.00672000000000000028	kWh/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
219	258	224	1	964.00	m┬│	0.60	1639.00	CHF	0.60	234.94	EP	100	1690000.000	kg	0.000569999999999999977	m┬│/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
192	212	216	1	16020.00	kWh	0.89	21004.00	CHF	0.89	8166996.00	EP	0.89	10000000.000	kg	0.00160000000000000008	kWh/kg	\N	0.0200000000000000004		\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	Rawmilk	Electrcity consumption CIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	See option cold sterilization
222	262	240	1	2700.00	kWh	150.00	101.00	CHF	0.04	917.64	EP	100	10000000.000	kg	0.000270000000000000003	kWh/kg	\N	0.00133000000000000002	cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
201	240	241	1	60000.00	kg	0.60	30000.00	CHF	0.60	0.02	EP	0.6	1690000.000	kg	0.0354999999999999968	kg/kg	\N	0.0149999999999999994	increase batch size to 20000l	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk	CIP milk losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
223	262	243	1	675.00	kg	100.00	2700.00	CHF	100.00	7.13	EP	100	10000000.000	kg	6.99999999999999939e-05	kg/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
308	281	205	1	302640.00	MJ	52.00	7675.72	CHF	52.00	20488.00	EP	52	2368.400	unit	127.782470000000004	MJ/unit	\N	55.8999999999999986	new shower head	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	no plan?		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	half of water consumption
304	282	225	2	579063.00	kg	100.00	318500.00	CHF	100.00	202125.00	EP	100	9407000.000	kg	0.0553999999999999979	kg/kg	\N	0.0200000000000000004	Pushing milk	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	total raw milk 2017	pushing losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Reducing milk waste by using a plug\n(correct)
310	286	261	1	13.00	kg	100.00	877.00	CHF	100.00	1703.39	EP	100	20.000	kg	0.650000000000000022	kg/kg	\N	0.100000000000000006	repair cooling unit	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	total amount of refrigerant	refrigerant loss	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	repair leakage of cooling unit
232	265	241	1	120000.00	kg	1.20	60000.00	CHF	1.20	35220000.00	EP	100	1690000.000	kg	0.0710100000000000037	kg/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
233	265	224	1	964.00	m┬│	1.54	1639.00	CHF	1.54	234.94	EP	100	1690000.000	kg	0.000569999999999999977	m┬│/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
307	281	259	2	2273.60	m┬│	80.00	3684.00	CHF	80.00	8392.00	EP	80	2368.400	unit	0.95996999999999999	m┬│/unit	\N	0.419999999999999984	new shower head	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	average of shower head		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	half of water consumption
221	262	238	1	16472.00	kWh	26.31	615.00	CHF	0.60	8519.86	EP	100	10000000.000	kg	0.00164999999999999999	kWh/kg	\N	0.0019	cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
215	258	241	1	60000.00	kg	0.60	30000.00	CHF	0.60	0.02	EP	.6	1690000.000	kg	0.0354999999999999968	kg/kg	\N	0.0149999999999999994	incresed bach size 20000l	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk	Milk losses (during CIP)	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
228	264	238	1	126285.00	kWh	201.73	4717.00	CHF	4.62	8519.86	EP	100	10000000.000	kg	0.0126300000000000006	kWh/kg	\N	0.0019	hot sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
227	264	224	1	3488.00	m┬│	5.57	5929.00	CHF	5.57	234.94	EP	100	10000000.000	kg	0.000349999999999999996	m┬│/kg	\N	0.000100000000000000005	hot sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
229	264	240	1	6075.00	kWh	337.50	3720.00	CHF	1.58	917.64	EP	100	10000000.000	kg	0.000609999999999999974	kWh/kg	\N	9.00000000000000057e-05	hot sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
196	215	225	2	464000.00	kg	80.00	256000.00	CHF	80.00	1667704160.00	EP	80	10000000.000	kg	0.0463999999999999968	kg/kg	\N	0.0200000000000000004	Milk powder from milk/water phase	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	rawmilk	push losses in milk/water phase	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Milk/water phase of pushing milk at process start and end is dischared to waste water. It could be collected and reused to produce milk powder.
230	265	238	1	11362.00	MWh	18.15	424.00	CHF	0.42	8519.86	EP	100	1690000.000	kg	0.00672000000000000028	MWh/kg	\N	0.00391999999999999987	2x	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
231	265	238	1	8274.00	MWh	13.22	309.00	CHF	0.30	8519.86	EP	100	1690000.000	kg	0.00489999999999999984	MWh/kg	\N	0.00391999999999999987	2x	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	Cheese milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
234	243	238	1	2731.00	kWh	100.00	102000.00	CHF	100.00	0.14	EP	100	10000000.000	kg	0.000270000000000000003	kWh/kg	\N	0.0019	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
236	243	224	1	450.00	m┬│	0.72	765.00	CHF	0.72	0.00	EP	100	10000000.000	kg	5.00000000000000024e-05	m┬│/kg	\N	0.200000000000000011	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
235	243	240	1	2700.00	kWh	150.00	101.00	CHF	0.04	0.51	EP	100	10000000.000	kg	0.000270000000000000003	kWh/kg	\N	0.00133000000000000002	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
237	243	238	1	4000.00	MWh	146.47	102000.00	CHF	100.00	0.14	EP	100	1690000.000	MWh	0.00237000000000000014	MWh/MWh	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	rawmilk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
238	239	230	1	2731.00	MWh	100.00	102000.00	CHF	100.00	0.00	EP	100	8000.000	kg	0.341370000000000007	MWh/kg	\N	0.800000000000000044	test	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	test		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
239	257	241	1	150000.00	l	50.00	3000.00	CHF	10.00	1056600.00	EP	100	800.000	kJ	187.5	l/kJ	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	test		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
197	227	226	1	76700.00	kWh	10.00	9204.00	CHF	10.00	17741668.26	EP	10	1598.000	m┬▓	47.9975000000000023	kWh/m┬▓	\N	23	L.E.D	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	area	specific_lighting	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Replace old lightbulbs with new LED lights
193	212	223	1	150000.00	kWh	5.49	5599.80	CHF	5.49	20405731.59	EP	5.49	10000000.000	kg	0.0149999999999999994	kWh/kg	\N	0	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Rawmilk	Heat consumption CIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Process equipment and tanks must be sterilized with hot water @85┬░C. At cold sterilization by adding ~0.03% of an eco-friendly disinfection chemical to the cleaning water no heat is required, and the water consumption can be reduced.
189	209	215	1	60000.00	kg	0.60	30000.00	CHF	0.60	211320000.00	EP	0.6	1650000.000	kg	0.0363600000000000034	kg/kg	\N	0.0100000000000000002	Increase batch size of cheese milk for pasteurization	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Cheese milk production	Cheese milk losses at pasteurizing and CIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Resource consumption of CIP after pasteurizing of cheese milk (and other milk) is equal for a batch size of 10'000 kg and 20'000 kg. At a batch sizes of 20'000 kg, Milk losses in water/milk phase (3.5% ) and resource consumption of pasteurizing / CIP can be reduced.
469	375	272	1	50727.00	kWh	100.00	12994.00	CHF	100.00	10.78	EP	100	220.000	m┬│	230.577269999999999	kWh/m┬│	\N	200	PV-Anlage f├╝r Eigenstromproduktion	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Produzierte Menge Bier/ Jahr	Energieaufwand zum K├╝hlen/ Jahr	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ein Teil des ben├Âtigten Stroms mittels PV-Anlage auf dem Dach erzeugen
476	386	320	1	500000.00	kg	100.00	1000.00	CHF	100.00	0.46	EP	100	2000.000	unit	250	kg/unit	\N	200	Reuse last rinse water	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Product	water cons per prod. unit product	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
472	381	307	1	200000.00	kg	100.00	100000.00	CHF	100.00	40.00	EP	100	160000.000	kg	1.25	kg/kg	\N	1.05000000000000004	Reduce Milk Loses	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Loss of 20%		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
240	267	1	1	6000.00	kg	60.00	12.00	CHF	60.00	2760.00	EP	60	5000.000	kg	1.19999999999999996	kg/kg	\N	1.30000000000000004	Water as ingredient	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	Beer		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
241	267	99	1	4000.00	MJ	80.00	1600.00	CHF	80.00	72200.00	EP	80	5000.000	kg	0.800000000000000044	MJ/kg	\N	1	Heat for brewing	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	Beer		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
297	281	258	1	2273664.00	l	100.00	5004.00	CHF	100.00	1043653.00	EP	100	2030.000	m┬▓	1120.03152999999998	l/m┬▓	\N	230	current state	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	xx		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
302	285	262	2	697.49	kg	100.00	722.86	CHF	100.00	837542.76	EP	100	2030.000	m┬▓	0.343590000000000007	kg/m┬▓	\N	0.100000000000000006	current state plastic	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	xx		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
298	281	259	2	2273664.00	l	100.00	3683.00	CHF	100.00	8391114.00	EP	100	2030.000	m┬▓	1120.03152999999998	l/m┬▓	\N	550		\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	xx		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
300	281	258	1	1136832.00	l	50.00	2502.00	CHF	50.00	521826.50	EP	50	40000.000	m┬▓	28.4207999999999998	l/m┬▓	\N	8	current state	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	yy	flowrate shower	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	water saving shower head
296	279	230	1	494000.00	MJ	100.00	13711.00	CHF	100.00	2050000.00	EP	100	2030.000	m┬▓	243.34975	MJ/m┬▓	\N	80		\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	xx		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
299	281	260	1	258699.00	MJ	100.00	7383.00	CHF	100.00	20614721.00	EP	100	2030.000	m┬▓	127.437929999999994	MJ/m┬▓	\N	60		\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	xx		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
294	279	205	1	582000.00	MJ	100.00	16900.00	CHF	100.00	39400000.00	EP	100	2030.000	m┬▓	286.699509999999975	MJ/m┬▓	\N	80	Current state	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	Hospital		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
335	288	80	2	7101.00	kg	100.00	0.00	CHF	100.00	845019000.00	EP	100	675000.000	t	0.0105199999999999998	kg/t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
328	288	266	2	1501875.00	kg	100.00	0.00	CHF	100.00	62875600650.00	EP	100	675000.000	t	2.22500000000000009	kg/t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
345	292	2	1	6338250.00	kWh	100.00	633825.00	CHF	100.00	1476812250.00	EP	100	7101.000	kg	892.585550000000012	kWh/kg	\N	800	Clinker production, 32% RDF, Dust filter	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	dust filtered		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 2:\n67% petcoke and dust reduction (ESP & fabric) measures (no Nox measures)
468	378	272	1	1191.00	kWh	2.35	305.36	CHF	2.35	10.78	EP	100	238.220	m┬│	4.99957999999999991	kWh/m┬│	\N	1.44999999999999996	Stromeinsparung durch Einsatz Entionisierungsanlage	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Umkehrosmose	Energieaufwand / m3 entionisiertem Wasser	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Umkehrosmoseanlage durch Entioniserungsanlgae ersetzen
314	270	225	2	57906.30	kg	10.00	31850.00	CHF	10.00	203945.99	EP	0.01	1650000.000	kg	0.0350900000000000031	kg/kg	\N	0.0100000000000000002	Increase cheese milk batch size	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	cheese milk processed 2018	pushing losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Reducing resource use by increasing cheese milk batch sizes thus reducing the number of CIP cleans required per kg milk processed.
325	293	215	1	840.00	kg	8.40	84.00	CHF	8.40	2958480.00	EP	8.4	10000.000	kg	0.0840000000000000052	kg/kg	\N	0.100000000000000006	Calf feeding	\N	\N	\N	\N	\N	\N	\N	\N	30	30	30	1	total raw milk	feed milk per kg raw milk avaliable	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Using raw milk losses to feed calves in a cow farm
341	288	266	2	1501875.00	kg	100.00	0.00	CHF	100.00	62875600650.00	EP	100	675000.000	t	2.22500000000000009	kg/t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
342	288	80	2	7101.00	kg	100.00	0.00	CHF	100.00	845019000.00	EP	100	675000.000	t	0.0105199999999999998	kg/t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
473	382	315	1	2000000.00	kWh	100.00	146000.00	Euro	100.00	0.02	EP	100	200000.000	m┬│	10	kWh/m┬│	\N	10	x	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Natural Gas	Natural Gas Energy Conversion	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	x
338	295	2	1	600066.00	kWh	33.30	78588.00	CHF	33.30	305913646.80	EP	33.3	2351750.000	kg	0.00152999999999999989	kWh/kg	\N	0	Roller Door Closing	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	raw milk 2017 in the summer months	reduced cooling per kg of milk from shutting roller door	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Closing the external roller doors to reduce cooling
331	288	264	1	70522000.00	kg	100.00	7757463.00	CHF	100.00	1497427465.00	EP	100	675000.000	t	104.477040000000002	kg/t	\N	71	Clinker production, 32% RDF, no filters	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 1:\n 67% petcoke, no dust and Nox reduction measures
346	290	267	1	4860000.00	kg	100.00	486000.00	CHF	100.00	10011600000.00	EP	100	675000.000	t	7.20000000000000018	kg/t	\N	6.5	Clinker production, 32% RDF, NOx treatment	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 3:\n67% petcoke and NOx reduction measures (no dust measures)
305	279	205	1	582000.00	MJ	100.00	14761.00	CHF	100.00	39400.00	EP	100	2030.000	m┬▓	286.699509999999975	MJ/m┬▓	\N	80	district heating	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	hotel area		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	improve environmental impact by substitute with district heating
306	281	258	1	2273.60	m┬│	80.00	3763.20	CHF	80.00	1044.00	EP	80	2368.400	unit	0.95996999999999999	m┬│/unit	\N	0.419999999999999984	new shower head	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	average flow of shower head		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	half of water consumption
309	279	230	1	494000.00	MJ	100.00	13711.00	CHF	100.00	2050.00	EP	100	2030.000	m┬▓	243.34975	MJ/m┬▓	\N	80	district heating	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	hotel area		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	improve environmental impact by substitute with district heating
311	286	263	2	13.00	kg	100.00	0.00	CHF	100.00	10588.50	EP	100	20.000	kg	0.650000000000000022	kg/kg	\N	0.100000000000000006	repair cooling unit	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	0	total amount of refrigerant	refrigerant loss	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	repair leakage of cooling unit
333	292	2	1	6338250.00	kWh	100.00	633825.00	CHF	100.00	1476812250.00	EP	100	7101.000	kg	892.585550000000012	kWh/kg	\N	890	Clinker production, 32% RDF, Dust filter	\N	\N	\N	\N	\N	\N	\N	\N	95	95	95	1	dust filtered		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 2:\n67% petcoke and dust reduction (ESP & fabric) measures (no Nox measures)
313	282	225	2	57906.30	kg	10.00	31850.00	CHF	10.00	203945988.60	EP	10	1650000.000	kg	0.0350900000000000031	kg/kg	\N	0.0100000000000000002	Pushing milk	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	cheese milk processed 2018	pushing losses	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Reducing milk losses by using a plug in CIP cleaning
339	273	249	1	2371000.00	kWh	100.00	102000.00	CHF	100.00	322693100.00	EP	100	62559000.000	kg	0.0379000000000000031	kWh/kg	\N	0.0500000000000000028	Wastewater Heat Exchanger	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Waste water to produce heat	Waste water to produce heat	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	There is approximately 30 deg C lost in the wastewater. This could be recovered with a heat exchanger.
326	276	249	1	150321.40	kWh	6.34	6466.80	CHF	6.34	20458742.54	EP	6.34	9407000.000	kg	0.0159800000000000011	kWh/kg	\N	0	Cold Sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	70	70	70	1	total raw milk processed 2017	Heat consumption for CIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Current cleaning involves sterilisation at 85┬░C. Chemicals could be added instead, reducing the heat, electricity and water consumption.
352	301	273	1	136550.00	MJ	5.00	5100.00	CHF	5.00	3428770.50	EP	5	10000000.000	kg	0.0136600000000000003	MJ/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Raw Milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
363	302	280	1	136550.00	kWh	5.00	5100.00	CHF	5.00	18500000.00	EP	5	10000000.000	kg	0.0136600000000000003	kWh/kg	\N	0	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Raw Milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Insteat of 85┬░C:\nadding 0.03% of eco-friendly disinfection chemical -> no heat required & reduced Water consumption
340	288	265	2	594599.00	t	100.00	22341504.00	CHF	100.00	273515540000.00	EP	100	675000.000	t	0.880889999999999951	t/t	\N	0.810000000000000053	Clinker production, 32% RDF, Dust filter & NOx treatment	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 4:\n 67% petcoke and dust and NOx reduction measures
343	288	264	1	70522000.00	kg	100.00	7757463.00	CHF	100.00	1497427465.00	EP	100	675000.000	t	104.477040000000002	kg/t	\N	90	Clinker production, 32% RDF, no filters	\N	\N	\N	\N	\N	\N	\N	\N	99	99	99	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 1:\n 67% petcoke, no dust and Nox reduction measures
329	288	265	2	594599.00	t	100.00	22341504.00	CHF	100.00	273515540000.00	EP	100	675000.000	t	0.880889999999999951	t/t	\N	0.849999999999999978	Clinker production, 32% RDF, Dust filter & NOx treatment	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	tons clinker produced (annual)		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Co-processing scenario 4:\n 67% petcoke and dust and NOx reduction measures
364	302	276	1	3130000.00	kg	5.00	2945.00	CHF	5.00	14398000.00	EP	5	15000000.000	kg	0.208669999999999994	kg/kg	\N	0.0500000000000000028	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	Raw Milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
366	300	278	2	464000.00	kg	80.00	256000.00	CHF	80.00	1624000000.00	EP	80	10000000.000	kg	0.0463999999999999968	kg/kg	\N	0.0200000000000000004	Milk powder	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Raw Milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Milk/water phase could be collected and reused to produce milk powder instead of discharging it to waste water
358	302	281	1	18000.00	kWh	1.00	23600.00	CHF	1.00	9797040.00	EP	1	10000000.000	kg	0.00179999999999999995	kWh/kg	\N	0.0200000000000000004	Cold sterilisation	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	Raw Milk	Electricity consumption CIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
396	302	276	1	50080000.00	kg	80.00	53010.00	CHF	90.00	230368000.00	EP	80	486246.000	unit	102.993139999999997	kg/unit	\N	200	&lt;fsay&lt;df	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	kgjkhtest		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	fh&lt;y&lt;fsd
395	300	279	2	31300000.00	kg	50.00	23560.00	CHF	40.00	16536000.00	EP	60	465864.000	g	67.1869899999999944	kg/g	\N	50	gdsxdfbxcgfn	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	gdstest		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
474	384	320	2	10000000.00	kg	100.00	10000.00	Euro	100.00	9.20	EP	100	1000000.000	t	10	kg/t	\N	9	Recycle	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	concrete	wastewater / t concrete	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Recycle alkaline wastewater
397	300	279	2	31300000.00	kg	50.00	29450.00	CHF	50.00	13780000.00	EP	50	74485646874.000	g	0.000420000000000000017	kg/g	\N	4	ngdgndf	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	z5erhtest		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hjktf
398	302	276	1	43820000.00	kg	70.00	41230.00	CHF	70.00	230368000.00	EP	80	877486.000	ha	71.3401700000000005	kg/ha	\N	90	gdsdgfdgh	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	pl├Âighztest		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	dkhd
375	307	287	1	19000000.00	kg	95.00	5700000.00	CHF	95.00	106260160000.00	EP	95	1000.000	kg	19000	kg/kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	per ton milk		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
357	297	277	1	60000.00	kg	0.60	30000.00	CHF	0.60	210000000.00	EP	0.6	2000000.000	kg	0.0299999999999999989	kg/kg	\N	0.0100000000000000002	Increase batch Size	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Raw Milk	Milk loss at Pasteurization	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Resource consumption of CIP after pasteurizing is equal for a batch size of 10'000kg and 20'000kg (-> 3.5%)
195	213	223	1	2005000.00	kWh	73.42	74888.40	CHF	73.42	272894137.22	EP	73.42	25000000.000	kg	0.0801999999999999935	kWh/kg	\N	0.0500000000000000028	Wastewater heat exhanger	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	Hot process water	Process water heating	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Waste water temperature is ~ 30┬░C. With a waste water heat exchager energy cold be recovered to preheat process water.
482	393	333	1	5317515.00	kg	8.50	95115.00	CHF	8.50	22076.03	EP	8.5	9407000.000	kg	0.56527000000000005	kg/kg	\N	0	Cold Desinfection Helades	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	raw milk	Kg Water/ kg Raw Milk	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
486	393	330	1	616460.00	kWh	26.00	26520.00	CHF	26.00	84.02	EP	26	9407000.000	kg	0.0655300000000000049	kWh/kg	\N	0.0400000000000000008	increase Batch size to 20000	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	0	raw milk	kWh Fernw├ñrme / kg raw milk	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
399	317	272	1	49700.00	kWh	97.98	12731.52	CHF	97.98	11.60	EP	97.98	220.000	m┬│	225.909089999999992	kWh/m┬│	\N	180	R├╝ckk├╝hlung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├ñlteenergie/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung wird kurzgeschlossen da Abluft angesogen wird.
406	325	272	1	7608.90	kWh	14.35	1864.64	CHF	14.35	1.78	EP	14.35	220.000	m┬│	34.5859099999999984	kWh/m┬│	\N	25	K├╝hlen	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier/a	G├ñrung/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
427	321	293	2	38050.00	kg	100.00	0.00	CHF	100.00	131.81	EP	100	220.000	m┬│	172.954550000000012	kg/m┬│	\N	173	Treber	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Treber pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Treber f├ñllt als Abfall an
426	342	293	1	37680.00	kg	100.00	7000.00	CHF	100.00	130.53	EP	100	219.000	m┬│	172.054789999999997	kg/m┬│	\N	157.300000000000011	Erh├Âhung der Maischetemperatur	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Eingesetztes Malz pro Produziertes Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wen die Maischetemperatur um 5┬░C auf 63┬░C erh├Âht wird, lassen sich bis zu 8% Malz einsparen
411	331	276	1	445.40	kg	0.03	2.21	CHF	0.03	0.00	EP	0.034	220.000	m┬│	2.02455000000000007	kg/m┬│	\N	2		\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier pro Jahr	CIP-Reinigungswasser pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
408	333	290	1	117766.12	MJ	13.00	3049.04	CHF	13.00	2.13	EP	13.00	220.000	m┬│	535.300550000000044	MJ/m┬│	\N	208.800000000000011	W├ñrme f├╝r Bier	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier/a	Gas pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
419	335	283	2	1076.60	m┬│	100.00	2099.00	CHF	100.00	4.00	EP	100	220.000	m┬│	4.89364000000000043	m┬│/m┬│	\N	4.70000000000000018	keine	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier pro Jahr	Abwasser pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
407	326	272	1	9408.00	kWh	17.75	2306.43	CHF	17.75	2.19	EP	17.75	220.000	m┬│	42.7636400000000023	kWh/m┬│	\N	21.8099999999999987	K├╝hlraum	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier/a	Energieeinsparung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	K├╝hlraum ersetzen durch einen effizienteren
428	344	272	1	31702.00	kWh	59.81	7771.71	CHF	59.81	7.40	EP	59.81	220.000	m┬│	144.099999999999994	kWh/m┬│	\N	128.330000000000013	Reifung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier/a	Reifung/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Verk├╝rzung der Reifezeit von 12 auf 10 Wochen
401	315	272	1	51411.79	kWh	97.00	12604.16	CHF	97.00	11.98	EP	97.00	220.000	m┬│	233.68995000000001	kWh/m┬│	\N	180	R├╝ckk├╝hlung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├╝hlung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung wird kurzgeschlossen, da Abluft angesaugt wird
400	314	272	1	49700.00	kWh	97.98	12731.52	CHF	97.98	11.60	EP	97.98	220.000	m┬│	225.909089999999992	kWh/m┬│	\N	180	R├╝ckk├╝hlung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├ñltemenge/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	R├╝ckk├╝hlung wird kurzgeschlossen da Abluft angesaugt wird.
417	333	276	1	1310000.00	kg	100.00	6508.22	CHF	100.00	0.60	EP	100	220.000	m┬│	5954.54544999999962	kg/m┬│	\N	3500	Wasser Pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier/a	Wasser/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
420	338	283	2	1043.00	m┬│	100.00	2033.85	CHF	100.00	3.68	EP	100	220.000	m┬│	4.7409100000000004	m┬│/m┬│	\N	4.70000000000000018	Keine	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier pro Jahr	Abwasser pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
423	327	290	1	905893.20	MJ	100.00	23454.13	CHF	100.00	16.35	EP	100	220.000	m┬│	4117.69635999999991	MJ/m┬│	\N	4000	Neuer Heizkessel	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	W├ñrme / Bier pro Jahr	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Alter Heizkessel wird durch neuen Heizkessel ersetzt. Wirkungsgrad von 90% auf 94%.
415	335	276	1	1310000.00	kg	100.00	2512.60	CHF	100.00	0.60	EP	100	220.000	m┬│	5954.54544999999962	kg/m┬│	\N	5200	Manuelle Reinigung Brauraum	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Wasser / Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Brauraum wird mit Schlauch ohne D├╝se gereinigt. Annahmen pro Tag: 30 Minuten mit 40 L/min
421	342	276	1	1310.00	t	100.00	2531.00	CHF	100.00	0.11	EP	100	218.000	t	6.00917000000000012	t/t	\N	4.70000000000000018		\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Hergestelltes Bier	Eingesetztes Wasser pro Produziertes Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
410	331	276	1	509980.00	m┬│	40.98	2530.52	CHF	40.98	0.00	EP	40.98	220.000	m┬│	2318.09090999999989	m┬│/m┬│	\N	579	Reinigungswasser Rest	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Manuelle Reinigung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Spard├╝sen an Schl├ñuchen zur manuellen Reinigung k├Ânnten den Verbrauch reduzieren. Wasserverbrauch: 23l/min ├á 1 h/d.\nReduktion: Annahme 75% Einsparung
425	343	283	2	120.00	m┬│	12.06	99.56	CHF	12.06	1.73	EP	100	220.000	m┬│	0.54544999999999999	m┬│/m┬│	\N	0.400000000000000022	Wasser zum reinigen	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Bier/a	Abwasser f├╝rs abspritzen/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wasserspard├╝se
424	343	276	1	120000.00	kg	9.16	596.15	CHF	9.16	0.60	EP	100	220.000	m┬│	545.45455000000004	kg/m┬│	\N	400	Wasser zum reinigen	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier/a	Wasser zum abspritzen/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wasserspard├╝se
416	338	276	1	509980.00	kg	38.93	978.16	CHF	38.93	0.60	EP	100	220.000	m┬│	2318.09090999999989	kg/m┬│	\N	5200	Manuelle Reinigung Brauraum	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Wasser pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Brauereiraum wird mit Schlauch ohne D├╝se gereinigt. Wasserspard├╝se einf├╝gen. Pro Tag mindestens 30 min. mit 40 Liter pro Minuten
429	323	291	1	905893.20	MJ	100.00	23454.13	CHF	100.00	15.58	EP	100	220.000	m┬│	4117.69635999999991	MJ/m┬│	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Gas pro Jahr	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
457	357	290	1	181322.60	MJ	20.00	4700.00	CHF	20.00	3.27	EP	20	220.000	m┬│	824.193639999999959	MJ/m┬│	\N	800	Verbesserte W├ñrmenutzung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Menge Bier/ Jahr	W├ñrmeenergie/ m3 Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Masnahmenpaket mit Isolation, W├ñrmetauscher, W├ñrmepumpen
442	361	272	1	4494.41	kWh	8.86	1151.27	CHF	8.86	0.96	EP	8.86	220.000	m┬│	20.4291400000000003	kWh/m┬│	\N	20.4899999999999984	Ersatz Leuchtstoffr├Âhren 36W durch LED R├Âhren	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Beleuchtung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ersatz der 36W Leuchtstoffr├Âhren durch LED R├Âhren und Installierung von Lichtsensoren zur Reduktion der Beleuchtungszeit.
432	346	215	1	100000.00	kg	100.00	50000.00	CHF	100.00	352200000.00	EP	100	1.000	unit	100000	kg/unit	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	year	no	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
433	314	272	1	49204.79	kWh	97.00	12604.18	CHF	97.00	11.84	EP	100	220.000	m┬│	223.658140000000003	kWh/m┬│	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├╝hlung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
431	317	272	1	9118.00	kWh	17.97	2335.02	CHF	17.97	2.13	EP	17.97	16.000	m┬▓	569.875	kWh/m┬▓	\N	500	Abdichten	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Gek├╝hlte Raumfl├ñche	K├ñlteenergie/m^2 gek├╝hlt	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Spalt in T├╝re zum K├ñlteraum.
434	317	272	1	50726.59	kWh	100.00	12994.00	CHF	100.00	11.84	EP	100	220.000	m┬│	230.575410000000005	kWh/m┬│	\N	180	PV-Anlage	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Stromverbrauch / Jahr	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Eigenproduktion von Strom mit PV-Anlage auf Dach.
435	349	299	2	38050.00	kg	100.00	150.00	CHF	100.00	0.00	EP	100	220.000	m┬│	172.954550000000012	kg/m┬│	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Treberabfall Pro bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
436	351	300	2	38050.00	kg	100.00	0.00	CHF	100.00	0.00	EP	100	220.000	m┬│	172.954550000000012	kg/m┬│	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Malzkuchen pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
448	363	272	1	50727.00	kWh	100.00	12994.00	CHF	100.00	10.78	EP	100	220.000	m┬│	230.577269999999999	kWh/m┬│	\N	200	PV-Anlage f├╝r Eigenstromproduktion	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Stromverbrauch / Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Bereitstellen eines gewissen teils des J├ñhrlich ben├Âtigten Stroms durch eine PV-Anlage auf dem Dach der Brauerei.
460	373	272	1	3810.81	kWh	8.25	1155.00	CHF	8.25	0.89	EP	8.25	220.000	m┬│	17.3218600000000009	kWh/m┬│	\N	20	Ersatz der FL - durch LED Leuchtmittel	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Beleuchtung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch den Ersatz der herk├Âmmlichen Fl-Lampen durch LED kann elektrische Energie eingespart werden. 40Stk., CAPEX 25.- CHF pro Leuchmittel. Lebensdauer 15 Jahre
485	393	277	1	329245.00	kg	3.50	180950.00	CHF	3.50	1550.74	EP	3.5	9407000.000	kg	0.0350000000000000033	kg/kg	\N	0	milk powder production	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	raw milk	Einfahrverluste(kg) / Raw milk(kg)	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	use milk losses to produce milk powder
451	365	272	1	4559.36	kWh	8.25	1169.93	CHF	8.25	0.98	EP	8.25	220.000	m┬│	20.7243600000000008	kWh/m┬│	\N	20	Ersatz der FL- durch LED- Lampen	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Beleuchtung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch den Ersatz der herk├Âmmlichen FL-Lampen durch LED- Technologie kann elektrische Energie f├╝r die Beleuchtung eingespart werden. 40 Stk., Capex: 25.- pro Umbau Leuchte Lebensdauer: 15 a
437	338	272	1	30339.57	kWh	59.81	7771.71	CHF	59.81	7.08	EP	59.81	220.000	m┬│	137.907139999999998	kWh/m┬│	\N	128.330000000000013	Reifung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Energie Reifung/Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Verk├╝rzung der Reifezeit von 12 auf 10 Wochen.
439	360	272	1	4492.80	kWh	8.86	1151.27	CHF	8.86	1.05	EP	8.86	220.000	m┬│	20.4218200000000003	kWh/m┬│	\N	20.3999999999999986	Ersatz Leuchtstoffr├Âhren 36W --&gt; LED	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Beleuchtung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ersetzen der Leuchtstoffr├Âhren 36w durch LED R├Âhren 16w plus 5 lichtsensoren, Reduktion der Stunden um 1/2.
438	338	272	1	32525.89	kWh	64.12	8331.75	CHF	64.12	7.59	EP	64.12	220.000	m┬│	147.844950000000011	kWh/m┬│	\N	89.5999999999999943	K├╝hlraum	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Energie K├╝hlraum pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ersetzen K├╝hlraum
446	363	272	1	49205.19	kWh	97.00	12604.18	CHF	97.00	10.46	EP	97	220.000	m┬│	223.659950000000009	kWh/m┬│	\N	185.5	Anpassung Ein- und Auslass der K├ñlteanlage	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├╝hlung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch Anpassung des Standorts des Einlasses der K├ñlteanlage kann die R├╝ckk├╝hlung der Anlage optimiert werden.
450	318	272	1	32955.00	kWh	65.00	8446.10	CHF	65.00	7.69	EP	65	220.000	m┬│	149.795449999999988	kWh/m┬│	\N	125	Verk├╝rzung der Reifezeit	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Reifung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch die Verk├╝rzung der Reifezeit des Bieres von 12 auf 10 Wochen, in Anbetracht des Brauens einer anderen Biersorte, kann elektrische Energie eingespart werden. Energie -5280 kWh/a Lebensdauer 20 a,
449	318	272	1	49179.00	kWh	97.00	12604.18	CHF	97.00	11.48	EP	97	220.000	m┬│	223.540909999999997	kWh/m┬│	\N	185	Einlass Luft f├╝r R├╝ckk├╝hlung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├╝hlung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch die Versetzung des Einlasses der Luft f├╝r die R├╝ckk├╝hlung kann diese effizienter genutzt werden.  Energie -8360 kWh/a , CAPEX: 1500 .-, Lebensdauer 20 a
447	364	293	1	37680.00	kg	100.00	7000.00	CHF	100.00	130.53	EP	100	220.000	m┬│	171.272729999999996	kg/m┬│	\N	157	Erh├Âhung der Maischetemperatur um 5┬░C	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Eingesetztes Malz pro Produziertes Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wen die Maischetemperatur um 5┬░C auf 63┬░C erh├Âht wird, lassen sich bis zu 8% Malz einsparen
453	366	272	1	4696.42	kWh	8.86	1151.27	CHF	8.86	1.10	EP	8.86	220.000	m┬│	21.3473599999999983	kWh/m┬│	\N	21	LED Beleuchtung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pr0 Jahr	Beleuchtung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Auswechseln der FL R├Âhren durch LED
443	333	298	2	38050.00	kg	100.00	1900.00	CHF	100.00	66.00	EP	100	220.000	m┬│	172.954550000000012	kg/m┬│	\N	172.949999999999989		\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier	Treber pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wird als Viehfutter abgegeben
458	370	290	1	181322.60	MJ	20.00	4700.00	CHF	20.00	3.27	EP	20	220.000	m┬│	824.193639999999959	MJ/m┬│	\N	800	Verbesserte W├ñrmenutzung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Produzierte Biermenge/ Jahr	W├ñrmeenergie/ m3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Verluste beim Dampfkessel und Rohren verringern, W├ñrmetauscher bei Sudpfanne ausbauen, W├ñrmepumpen installieren
445	362	272	1	9408.00	kWh	18.55	2410.39	CHF	18.55	2.00	EP	18.55	220.000	m┬│	42.7636400000000023	kWh/m┬│	\N	21.8099999999999987	K├╝hlraum ersetzen	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	K├╝hlenergie pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	K├╝hlraum wird durch einen moderneren und besser ged├ñmmten Ersetzt
484	393	275	1	5362.00	kg	100.00	1877.00	CHF	100.00	8.68	EP	100	9407000.000	kg	0.000569999999999999977	kg/kg	\N	0	use raw milk to feed cows	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	raw milk	Kg SH/ kg Raw Milk	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
459	313	272	1	44805.85	kWh	97.00	13580.00	CHF	97.00	10.78	EP	100	220.000	m┬│	203.662949999999995	kWh/m┬│	\N	185	Einlass Luft f├╝r R├╝ckk├╝hlung	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	K├╝hlung pro m3 Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch die Versetzung des Einlass der Luft  f├╝r die R├╝ckk├╝hlung kann diese effizienter genutzt werden. Energie -8360 kWh/a. CAPEX 1500.- Lebensdauer:  20 Jahre
452	318	272	1	2763.25	kWh	5.00	709.05	CHF	5.00	0.59	EP	5	220.000	m┬│	12.5602300000000007	kWh/m┬│	\N	4	Sanierung des K├╝hlraumes	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Bier pro Jahr	Energie K├╝hlraum pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch die Sanierung der K├╝hlraumt├╝r kann K├╝hlenergie eingespart werden. Die bisherige T├╝r ist undicht und f├╝hrte zu Verlusten. 1/3 der urspr├╝nglichen Energie kann eingespart werden. Capex: 5'000.-  Lebensdauer: 20 a
461	313	272	1	2309.58	kWh	5.00	700.00	CHF	5.00	0.54	EP	5	220.000	m┬│	10.4980899999999995	kWh/m┬│	\N	4	Sanierung des K├╝hlraums	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Energie K├╝hlraum pro bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch die Sanierung des K├╝hlraums kann K├╝hlenergie eingespart werden. Die bisherige T├╝r ist undicht und f├╝hrt zu Verlusten. Ein Drittel der bisherigen Energie kann eingespart werden. CAPEX 5000.- Lebensdauer 20 Jahre
462	313	272	1	30024.54	kWh	65.00	9100.00	CHF	65.00	7.01	EP	65	220.000	m┬│	136.475179999999995	kWh/m┬│	\N	125	Verk├╝rzung der Reifzeit	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Reifung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch die Verk├╝rzung der Reifzeit von 12 Wochen auf 10 Wochen kann Energie eingespart werden. Energie -5280 kWh/a. Lebensdauer 50
464	375	272	1	49205.19	kWh	97.00	12604.18	CHF	97.00	10.46	EP	97	220.000	m┬│	230.577269999999999	kWh/m┬│	\N	185.5	Anpassung Ein- und Auslass der K├ñlteanlage	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Energieaufwand zur K├╝hlung/ produziertem Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Durch Anpassung des Standorts des Einlasses der K├ñlteanlage kann die R├╝ckk├╝hlung der Anlage optimiert werden.
463	374	293	1	37680.00	kg	100.00	7000.00	CHF	100.00	130.53	EP	100	220.000	m┬│	171.272729999999996	kg/m┬│	\N	157	Erh├Âhung der Maischetemperatur um 5┬░C	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Eingesetzte Malzmenge/ produziertem Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wen die Maischetemperatur um 5┬░C auf 63┬░C erh├Âht wird, lassen sich bis zu 8% Malz einsparen
465	356	272	1	9408.00	kWh	18.55	2410.39	CHF	18.55	2.00	EP	18.55	220.000	m┬│	42.7636400000000023	kWh/m┬│	\N	21.8099999999999987	K├╝hlraum ersetzen	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	0	Hergestelltes Bier pro Jahr	K├╝hlenergie/ Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	K├╝hlraum wird durch einen moderneren und besser ged├ñmmten Ersetzt
467	377	272	1	1191.00	kWh	2.35	305.00	CHF	2.35	10.78	EP	100	238.220	m┬│	4.99957999999999991	kWh/m┬│	\N	1.44999999999999996	Stromeinsparung durch Einsatz Deionisierungsanlage	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Umkehrosmose	ben├Âtigte kWh/m3 deionisiertes Wasser	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Umkehrosmosemaschine durch Deionisierungsanlage ersetzen
466	376	272	1	4494.41	kWh	8.86	1151.27	CHF	8.86	0.96	EP	8.86	220.000	m┬│	20.4291400000000003	kWh/m┬│	\N	20.4899999999999984	Ersatz Leuchtstoffr├Âhren 36W durch LED R├Âhren	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Hergestelltes Bier pro Jahr	Beleuchtung pro Bier	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ersatz der 36W Leuchtstoffr├Âhren durch LED R├Âhren und Installierung von Lichtsensoren zur Reduktion der Beleuchtungszeit.
478	388	322	1	220000.00	t	122.22	19800000.00	CHF	122.22	297000.00	EP	100	1200000.000	t	0.183329999999999993	t/t	\N	0.149999999999999994	Petcoke subsitution with RDF	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	t clinker produced	t petcoke / t clinker	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Petcoke burning
501	402	337	2	2508683.00	kg	100.00	0.00	CHF	100.00	0.98	EP	100	180000.000	t	13.9371299999999998	kg/t	\N	5.57000000000000028	NOx reduction	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	T petcoke consumption per year	kg NOx emitted per t petcoke	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	NSCR NOx with ammonia
500	401	331	1	167779.00	kWh	100.00	12850.00	CHF	100.00	37.00	EP	100	2030.000	m┬▓	82.6497499999999974	kWh/m┬▓	\N	75	District heat	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	Area hotel	Hotel heat usage per m┬▓	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Reduction of UBP not usage
502	403	336	2	150521.00	kg	100.00	0.00	CHF	100.00	0.21	EP	100	180000.000	t	0.836230000000000029	kg/t	\N	0.280000000000000027	Dust reduction	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	t petcoke consumption per year	kg dust emitted per t petcoke consumed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ESP filter to reduce dust emissions
513	407	80	2	150521.00	kg	100.00	0.00	CHF	100.00	0.02	EP	100	180000.000	t	0.836230000000000029	kg/t	\N	0.280000000000000027	Dust filter ESP	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	t petcoke	kg dust emitted per t petcoke	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
483	393	335	1	5362.00	kg	100.00	3753.00	CHF	100.00	28.30	EP	100	9407000.000	kg	0.000569999999999999977	kg/kg	\N	0	Heat recovery	\N	\N	\N	\N	\N	\N	\N	\N	100	100	100	1	raw milk	Kg PpA/ kg Raw Milk	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
487	393	332	1	288320.00	kWh	16.00	37760.00	CHF	16.00	147.04	EP	16	9407000.000	kg	0.0306500000000000002	kWh/kg	\N	0	molchsystem	\N	\N	\N	\N	\N	\N	\N	\N	90	90	90	1	raw milk	kWh Strom / raw milk kg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	negate milk losses through molchsystem
514	406	341	2	2508683.00	kg	100.00	0.00	CHF	100.00	0.10	EP	100	180000.000	t	13.9371299999999998	kg/t	\N	5.57000000000000028	NOx reduction SNCR	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	t petcoke	kg NOx emitted per t petcoke	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
560	443	80	2	150521.00	kg	100.00	0.00	CHF	100.00	0.02	EP	100	180000.000	t	0.836230000000000029	kg/t	\N	0.280000000000000027	Dust Fabric filter	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	t petcoke	kg dust emitted per t petcoke burned	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
561	444	343	1	1280000.00	GJ	100.00	38758400.00	CHF	100.00	0.00	EP	100	1197200.000	t	1.06916000000000011	GJ/t	\N	0.800000000000000044	Biogas use	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	t petcoke	GJ Biogas / t clinker	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	
562	446	272	1	3000000.00	kWh	33.54	1073247.00	CHF	100.00	2087.73	EP	100	500000.000	t	6	kWh/t	\N	4	Optimierung UO	\N	\N	\N	\N	\N	\N	\N	\N	80	80	80	1	treated water	Umkehrosmose	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Optimierung der Umkehrosmose
\.


--
-- Data for Name: t_cp_company_project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cp_company_project (id, allocation_id, prjct_id, cmpny_id) FROM stdin;
366	399	42102	3460
182	189	42077	3419
367	400	42096	3455
368	401	42100	3458
185	192	42077	3419
186	193	42077	3419
187	194	42077	3419
188	195	42077	3419
189	196	42077	3419
190	197	42079	3423
191	198	42079	3423
373	406	42100	3458
374	407	42100	3458
375	408	42100	3458
377	410	42098	3456
378	411	42098	3456
382	415	42102	3460
383	416	42096	3455
384	417	42100	3458
386	419	42102	3460
387	420	42096	3455
388	421	42099	3457
390	423	42102	3460
391	424	42100	3458
392	425	42100	3458
393	426	42099	3457
394	427	42096	3455
395	428	42100	3458
396	429	42096	3455
398	431	42102	3460
399	432	42077	3422
400	433	42096	3455
401	434	42102	3460
402	435	42098	3456
403	436	42098	3456
404	437	42096	3455
405	438	42096	3455
406	439	42096	3455
287	294	42090	3447
410	443	42100	3458
289	296	42090	3447
290	297	42090	3447
291	298	42090	3447
292	299	42090	3447
293	300	42090	3447
295	302	42090	3447
297	304	42089	3446
298	305	42092	3447
299	306	42092	3447
300	307	42092	3447
301	308	42092	3447
302	309	42092	3447
303	310	42092	3447
304	311	42092	3447
306	313	42089	3446
307	314	42089	3446
416	449	42098	3456
417	450	42098	3456
418	451	42098	3456
419	452	42098	3456
420	453	42100	3458
424	457	42105	3462
319	326	42089	3446
426	459	42099	3457
321	328	42091	3448
322	329	42091	3448
427	460	42099	3457
324	331	42091	3448
326	333	42091	3448
327	334	42091	3448
428	461	42099	3457
429	462	42099	3457
328	335	42091	3448
430	463	42105	3462
431	464	42105	3462
331	338	42089	3446
332	339	42089	3446
333	340	42093	3448
334	341	42093	3448
335	342	42093	3448
336	343	42093	3448
338	345	42093	3448
339	346	42093	3448
432	465	42105	3462
433	466	42105	3462
435	468	42105	3462
436	469	42105	3462
439	472	42107	3471
440	473	42109	3478
441	474	42109	3478
443	476	42109	3477
445	478	42110	3474
449	482	42107	3471
450	483	42107	3471
451	484	42107	3471
452	485	42107	3471
453	486	42107	3471
454	487	42107	3471
467	500	42108	3472
468	501	42110	3474
469	502	42110	3474
472	513	42110	3474
473	514	42110	3474
482	560	42110	3474
483	561	42110	3474
484	562	42112	3486
\.


--
-- Data for Name: t_cp_is_candidate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cp_is_candidate (id, allocation_id, active) FROM stdin;
11	26	1
14	40	1
17	39	1
19	93	1
21	90	1
22	88	1
23	79	1
20	91	1
25	89	0
26	129	0
27	139	1
28	184	0
32	197	1
33	198	1
31	196	1
46	351	1
50	358	0
51	363	0
52	364	1
49	357	1
48	366	1
53	395	1
54	426	1
55	432	1
56	474	1
58	478	1
\.


--
-- Data for Name: t_cp_scoping_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_cp_scoping_files (id, prjct_id, cmpny_id, file_name) FROM stdin;
28	42077	3419	Milch_Benchmarks.docx
29	42091	3448	bref_cement_lime__mgoxide.pdf
\.


--
-- Data for Name: t_district; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_district (id, city_id, name) FROM stdin;
1	1	SEYHAN
2	1	Y├£RE─Ş─░R
3	1	SARI├çAM
4	1	├çUKUROVA
5	1	ALADA─Ş(KARSANTI)
6	1	CEYHAN
7	1	FEKE
8	1	─░MAMO─ŞLU
9	1	KARA─░SALI
10	1	KARATA┼Ş
11	1	KOZAN
12	1	POZANTI
13	1	SA─░MBEYL─░
14	1	TUFANBEYL─░
15	1	YUMURTALIK
16	2	ADIYAMAN
17	2	BESN─░
18	2	├çEL─░KHAN
19	2	GERGER
20	2	G├ûLBA┼ŞI
21	2	KAHTA
22	2	SAMSAT
23	2	S─░NC─░K
24	2	TUT
25	3	AFYONKARAH─░SAR
26	3	BA┼ŞMAK├çI
27	3	BAYAT
28	3	BOLVAD─░N
29	3	├çAY
30	3	├çOBANLAR
31	3	DAZKIRI
32	3	D─░NAR
33	3	EM─░RDA─Ş
34	3	EVC─░LER
35	3	HOCALAR
36	3	─░HSAN─░YE
37	3	─░SCEH─░SAR
38	3	KIZIL├ûREN
39	3	SANDIKLI
40	3	S─░NCANLI(S─░NANPA┼ŞA)
41	3	SULTANDA─ŞI
42	3	┼ŞUHUT
43	4	A─ŞRI
44	4	D─░YAD─░N
45	4	DO─ŞUBEYAZIT
46	4	ELE┼ŞK─░RT
47	4	HAMUR
48	4	PATNOS
49	4	TA┼ŞLI├çAY
50	4	TUTAK
51	5	AMASYA
52	5	83-TRIAL-G├ûYN├£CEK 185
53	5	236-TRIAL-G├£M├£┼ŞHACIK├ûY 223
54	5	165-TRIAL-HAMAM├ûZ├£ 276
55	5	0-TRIAL-MERZ─░FON 230
56	5	178-TRIAL-SULUOVA 24
57	5	51-TRIAL-TA┼ŞOVA 21
58	6	69-TRIAL-ALTINDA─Ş 235
59	6	54-TRIAL-├çANKAYA 193
60	6	87-TRIAL-ET─░MESGUT 271
61	6	233-TRIAL-KE├ç─░├ûREN 41
62	6	176-TRIAL-MAMAK 272
63	6	248-TRIAL-S─░NCAN 275
64	6	112-TRIAL-YEN─░MAHALLE 97
65	6	93-TRIAL-G├ûLBA┼ŞI 196
66	6	178-TRIAL-PURSAKLAR 48
67	6	162-TRIAL-AKYURT 45
68	6	167-TRIAL-AYA┼Ş 26
69	6	125-TRIAL-BALA 200
70	6	165-TRIAL-BEYPAZARI 279
71	6	141-TRIAL-├çAMLIDERE 170
72	6	224-TRIAL-├çUBUK 77
73	6	226-TRIAL-ELMADA─Ş 258
74	6	245-TRIAL-EVREN 164
75	6	268-TRIAL-G├£D├£L 242
76	6	81-TRIAL-HAYMANA 273
77	6	208-TRIAL-KALEC─░K 21
78	6	16-TRIAL-KAZAN 15
79	6	160-TRIAL-KIZILCAHAMAM 29
80	6	266-TRIAL-NALLIHAN 283
81	6	108-TRIAL-POLATLI 5
82	6	50-TRIAL-┼ŞEREFL─░KO├çH─░SAR 169
83	7	144-TRIAL-MURATPA┼ŞA 89
84	7	69-TRIAL-KEPEZ 192
85	7	219-TRIAL-KONYAALTI 232
86	7	82-TRIAL-AKSU 282
87	7	69-TRIAL-D├û┼ŞEMEALTI 119
88	7	232-TRIAL-AKSEK─░ 92
89	7	2-TRIAL-ALANYA 217
90	7	226-TRIAL-ELMALI 160
91	7	111-TRIAL-F─░N─░KE 287
92	7	98-TRIAL-GAZ─░PA┼ŞA 211
93	7	132-TRIAL-G├£NDO─ŞMU┼Ş 256
94	7	219-TRIAL-─░BRADI(AYDINKENT) 246
95	7	110-TRIAL-KALE(DEMRE) 75
96	7	209-TRIAL-KA┼Ş 39
97	7	173-TRIAL-KEMER 272
98	7	259-TRIAL-KORKUTEL─░ 281
99	7	130-TRIAL-KUMLUCA 40
100	7	243-TRIAL-MANAVGAT 45
101	7	187-TRIAL-SER─░K 209
102	8	14-TRIAL-ARTV─░N 146
103	8	227-TRIAL-ARDANU├ç 77
104	8	156-TRIAL-ARHAV─░ 48
105	8	88-TRIAL-BOR├çKA 186
106	8	46-TRIAL-HOPA 247
107	8	66-TRIAL-MURGUL(G├ûKTA┼Ş) 206
108	8	125-TRIAL-┼ŞAV┼ŞAT 9
109	8	54-TRIAL-YUSUFEL─░ 124
110	9	78-TRIAL-AYDIN 45
111	9	74-TRIAL-BOZDO─ŞAN 63
112	9	285-TRIAL-BUHARKENT(├çUBUKDA─ŞI) 293
113	9	203-TRIAL-├ç─░NE 261
114	9	118-TRIAL-GERMENC─░K 112
115	9	88-TRIAL-─░NC─░RL─░OVA 74
116	9	143-TRIAL-KARACASU 137
117	9	293-TRIAL-KARPUZLU 262
118	9	14-TRIAL-KO├çARLI 39
119	9	67-TRIAL-K├û┼ŞK 9
120	9	61-TRIAL-KU┼ŞADASI 21
121	9	62-TRIAL-KUYUCAK 165
122	9	55-TRIAL-NAZ─░LL─░ 224
123	9	293-TRIAL-S├ûKE 145
124	9	124-TRIAL-SULTANH─░SAR 218
125	9	85-TRIAL-D─░D─░M(YEN─░H─░SAR) 252
126	9	105-TRIAL-YEN─░PAZAR 137
127	10	248-TRIAL-BALIKES─░R 108
128	10	5-TRIAL-AYVALIK 161
129	10	199-TRIAL-BALYA 12
130	10	91-TRIAL-BANDIRMA 298
131	10	70-TRIAL-B─░GAD─░├ç 72
132	10	166-TRIAL-BURHAN─░YE 149
133	10	59-TRIAL-DURSUNBEY 43
134	10	85-TRIAL-EDREM─░T 204
135	10	54-TRIAL-ERDEK 181
136	10	78-TRIAL-G├ûME├ç 104
137	10	191-TRIAL-G├ûNEN 206
138	10	162-TRIAL-HAVRAN 131
139	10	165-TRIAL-─░VR─░ND─░ 279
140	10	121-TRIAL-KEPSUT 111
141	10	129-TRIAL-MANYAS 148
142	10	164-TRIAL-MARMARA 149
143	10	69-TRIAL-SAVA┼ŞTEPE 289
144	10	54-TRIAL-SINDIRGI 217
145	10	163-TRIAL-SUSURLUK 53
146	11	158-TRIAL-B─░LEC─░K 50
147	11	37-TRIAL-BOZ├£Y├£K 272
148	11	39-TRIAL-G├ûLPAZARI 281
149	11	275-TRIAL-─░NH─░SAR 88
150	11	89-TRIAL-OSMANEL─░ 158
151	11	163-TRIAL-PAZARYER─░ 254
152	11	109-TRIAL-S├û─Ş├£T 21
153	11	207-TRIAL-YEN─░PAZAR 142
154	12	158-TRIAL-B─░NG├ûL 249
155	12	296-TRIAL-ADAKLI 216
156	12	49-TRIAL-GEN├ç 283
157	12	86-TRIAL-KARLIOVA 204
158	12	42-TRIAL-KI─ŞI 19
159	12	217-TRIAL-SOLHAN 256
160	12	52-TRIAL-YAYLADERE 264
161	12	22-TRIAL-YED─░SU 257
162	13	155-TRIAL-B─░TL─░S 184
163	13	60-TRIAL-AD─░LCEVAZ 251
164	13	64-TRIAL-AHLAT 160
165	13	184-TRIAL-G├£ROYMAK 209
166	13	68-TRIAL-H─░ZAN 24
167	13	251-TRIAL-MUTK─░ 125
168	13	25-TRIAL-TATVAN 179
169	14	167-TRIAL-BOLU 155
170	14	157-TRIAL-D├ûRTD─░VAN 34
171	14	217-TRIAL-GEREDE 100
172	14	140-TRIAL-G├ûYN├£K 23
173	14	153-TRIAL-KIBRISCIK 292
174	14	108-TRIAL-MENGEN 56
175	14	186-TRIAL-MUDURNU 16
176	14	123-TRIAL-SEBEN 88
177	14	232-TRIAL-YEN─░├çA─ŞA 246
178	15	74-TRIAL-BURDUR 161
179	15	23-TRIAL-A─ŞLASUN 218
180	15	75-TRIAL-ALTINYAYLA(D─░RM─░L) 234
181	15	267-TRIAL-BUCAK 106
182	15	155-TRIAL-├çAVDIR 31
183	15	80-TRIAL-├çELT─░K├ç─░ 156
184	15	133-TRIAL-G├ûLH─░SAR 183
185	15	26-TRIAL-KARAMANLI 74
186	15	289-TRIAL-KEMER 246
187	15	165-TRIAL-TEFENN─░ 203
188	15	202-TRIAL-YE┼Ş─░LOVA 11
189	16	85-TRIAL-N─░L├£FER 36
190	16	123-TRIAL-OSMANGAZ─░ 146
191	16	214-TRIAL-YILDIRIM 17
192	16	91-TRIAL-B├£Y├£KORHAN 38
193	16	46-TRIAL-GEML─░K 93
194	16	186-TRIAL-G├£RSU 77
195	16	87-TRIAL-HARMANCIK 43
196	16	181-TRIAL-─░NEG├ûL 245
197	16	222-TRIAL-─░ZN─░K 91
198	16	134-TRIAL-KARACABEY 87
199	16	196-TRIAL-KELES 172
200	16	278-TRIAL-KESTEL 156
201	16	133-TRIAL-MUDANYA 148
202	16	108-TRIAL-MUSTAFAKEMALPA┼ŞA 55
203	16	58-TRIAL-ORHANEL─░ 297
204	16	138-TRIAL-ORHANGAZ─░ 14
205	16	167-TRIAL-YEN─░┼ŞEH─░R 40
206	17	28-TRIAL-├çANAKKALE 181
207	17	184-TRIAL-AYVACIK 167
208	17	51-TRIAL-BAYRAM─░├ç 217
209	17	7-TRIAL-B─░GA 87
210	17	156-TRIAL-BOZCAADA 7
211	17	127-TRIAL-├çAN 68
212	17	122-TRIAL-ECEABAT 190
213	17	19-TRIAL-EZ─░NE 229
214	17	177-TRIAL-GEL─░BOLU 203
215	17	55-TRIAL-G├ûK├çEADA(─░MROZ) 234
216	17	208-TRIAL-LAPSEK─░ 183
217	17	162-TRIAL-YEN─░CE 171
218	18	84-TRIAL-├çANKIRI 104
219	18	291-TRIAL-ATKARACALAR 254
220	18	97-TRIAL-BAYRAM├ûREN 292
221	18	145-TRIAL-├çERKE┼Ş 157
222	18	90-TRIAL-ELD─░VAN 225
223	18	25-TRIAL-ILGAZ 174
224	18	72-TRIAL-KIZILIRMAK 253
225	18	191-TRIAL-KORGUN 62
226	18	64-TRIAL-KUR┼ŞUNLU 64
227	18	159-TRIAL-ORTA 227
228	18	278-TRIAL-┼ŞABAN├ûZ├£ 292
229	18	182-TRIAL-YAPRAKLI 62
230	19	40-TRIAL-├çORUM 263
231	19	55-TRIAL-ALACA 133
232	19	38-TRIAL-BAYAT 36
233	19	19-TRIAL-BO─ŞAZKALE 89
234	19	109-TRIAL-DODURGA 275
235	19	241-TRIAL-─░SK─░L─░P 278
236	19	256-TRIAL-KARGI 262
237	19	94-TRIAL-LA├ç─░N 57
238	19	292-TRIAL-MEC─░T├ûZ├£ 252
239	19	239-TRIAL-O─ŞUZLAR(KARA├ûREN) 146
240	19	154-TRIAL-ORTAK├ûY 132
241	19	99-TRIAL-OSMANCIK 72
242	19	78-TRIAL-SUNGURLU 135
243	19	80-TRIAL-U─ŞURLUDA─Ş 94
244	20	196-TRIAL-DEN─░ZL─░ 61
245	20	2-TRIAL-ACIPAYAM 251
246	20	166-TRIAL-AKK├ûY 297
247	20	42-TRIAL-BABADA─Ş 292
248	20	158-TRIAL-BAKLAN 46
249	20	271-TRIAL-BEK─░LL─░ 60
250	20	29-TRIAL-BEYA─ŞA├ç 228
251	20	22-TRIAL-BOZKURT 5
252	20	200-TRIAL-BULDAN 200
253	20	147-TRIAL-├çAL 257
254	20	37-TRIAL-├çAMEL─░ 277
255	20	149-TRIAL-├çARDAK 292
256	20	269-TRIAL-├ç─░VR─░L 164
257	20	262-TRIAL-G├£NEY 152
258	20	221-TRIAL-HONAZ 281
259	20	265-TRIAL-KALE 268
260	20	297-TRIAL-SARAYK├ûY 33
261	20	91-TRIAL-SER─░NH─░SAR 241
262	20	121-TRIAL-TAVAS 202
263	21	271-TRIAL-SUR 201
264	21	122-TRIAL-BA─ŞLAR 2
265	21	11-TRIAL-YEN─░┼ŞEH─░R 230
266	21	7-TRIAL-KAYAPINAR 29
267	21	0-TRIAL-B─░SM─░L 3
268	21	148-TRIAL-├çERM─░K 1
269	21	138-TRIAL-├çINAR 126
270	21	182-TRIAL-├ç├£NG├£┼Ş 86
271	21	44-TRIAL-D─░CLE 182
272	21	225-TRIAL-E─Ş─░L 281
273	21	104-TRIAL-ERGAN─░ 117
274	21	198-TRIAL-HAN─░ 37
275	21	166-TRIAL-HAZRO 84
276	21	102-TRIAL-KOCAK├ûY 37
277	21	197-TRIAL-KULP 86
278	21	155-TRIAL-L─░CE 257
279	21	279-TRIAL-S─░LVAN 115
280	22	59-TRIAL-ED─░RNE 47
281	22	262-TRIAL-ENEZ 86
282	22	62-TRIAL-HAVSA 279
283	22	283-TRIAL-─░PSALA 41
284	22	259-TRIAL-KE┼ŞAN 190
285	22	222-TRIAL-LALAPA┼ŞA 78
286	22	239-TRIAL-MER─░├ç 8
287	22	2-TRIAL-S├£LEO─ŞLU(S├£LO─ŞLU) 253
288	22	102-TRIAL-UZUNK├ûPR├£ 8
289	23	178-TRIAL-ELAZI─Ş 69
290	23	74-TRIAL-A─ŞIN 80
291	23	180-TRIAL-ALACAKAYA 276
292	23	1-TRIAL-ARICAK 257
293	23	93-TRIAL-BASK─░L 264
294	23	269-TRIAL-KARAKO├çAN 8
295	23	177-TRIAL-KEBAN 22
296	23	97-TRIAL-KOVANCILAR 286
297	23	40-TRIAL-MADEN 272
298	23	195-TRIAL-PALU 297
299	23	190-TRIAL-S─░VR─░CE 81
300	24	256-TRIAL-ERZ─░NCAN 11
301	24	87-TRIAL-├çAYIRLI 215
302	24	136-TRIAL-─░L─░├ç(ILI├ç) 78
303	24	6-TRIAL-KEMAH 210
304	24	279-TRIAL-KEMAL─░YE 193
305	24	199-TRIAL-OTLUKBEL─░ 187
306	24	259-TRIAL-REFAH─░YE 194
307	24	282-TRIAL-TERCAN 243
308	24	222-TRIAL-├£Z├£ML├£ 100
309	25	10-TRIAL-PALAND├ûKEN 129
310	25	154-TRIAL-YAKUT─░YE 143
311	25	189-TRIAL-AZ─░Z─░YE(ILICA) 174
312	25	36-TRIAL-A┼ŞKALE 278
313	25	226-TRIAL-├çAT 40
314	25	234-TRIAL-HINIS 264
315	25	53-TRIAL-HORASAN 92
316	25	136-TRIAL-─░SP─░R 3
317	25	182-TRIAL-KARA├çOBAN 280
318	25	189-TRIAL-KARAYAZI 272
319	25	220-TRIAL-K├ûPR├£K├ûY 155
320	25	141-TRIAL-NARMAN 7
321	25	43-TRIAL-OLTU 35
322	25	121-TRIAL-OLUR 34
323	25	192-TRIAL-PAS─░NLER 249
324	25	231-TRIAL-PAZARYOLU 299
325	25	12-TRIAL-┼ŞENKAYA 87
326	25	220-TRIAL-TEKMAN 295
327	25	284-TRIAL-TORTUM 23
328	25	111-TRIAL-UZUNDERE 240
329	26	223-TRIAL-ODUNPAZARI 165
330	26	219-TRIAL-TEPEBA┼ŞI 279
331	26	112-TRIAL-ALPU 171
332	26	167-TRIAL-BEYL─░KOVA 190
333	26	49-TRIAL-├ç─░FTELER 204
334	26	201-TRIAL-G├£NY├£Z├£ 276
335	26	185-TRIAL-HAN 90
336	26	108-TRIAL-─░N├ûN├£ 246
337	26	114-TRIAL-MAHMUD─░YE 61
338	26	114-TRIAL-M─░HALGAZ─░ 232
339	26	42-TRIAL-M─░HALI├çCIK 126
340	26	294-TRIAL-SARICAKAYA 209
341	26	255-TRIAL-SEY─░TGAZ─░ 293
451	34	4-TRIAL-├çATALCA 143
342	26	61-TRIAL-S─░VR─░H─░SAR 132
343	27	8-TRIAL-┼ŞAH─░NBEY 21
344	27	164-TRIAL-┼ŞEH─░TKAM─░L 47
345	27	235-TRIAL-O─ŞUZEL─░ 33
346	27	181-TRIAL-ARABAN 240
347	27	24-TRIAL-─░SLAH─░YE 212
348	27	249-TRIAL-KARKAMI┼Ş 161
349	27	227-TRIAL-N─░Z─░P 1
350	27	229-TRIAL-NURDA─ŞI 244
351	27	220-TRIAL-YAVUZEL─░ 181
352	28	40-TRIAL-G─░RESUN 32
353	28	77-TRIAL-ALUCRA 125
354	28	244-TRIAL-BULANCAK 162
355	28	9-TRIAL-├çAMOLUK 202
356	28	149-TRIAL-├çANAK├çI 143
357	28	292-TRIAL-DEREL─░ 246
358	28	262-TRIAL-DO─ŞANKENT 133
359	28	156-TRIAL-ESP─░YE 216
360	28	33-TRIAL-EYNES─░L 164
361	28	258-TRIAL-G├ûRELE 48
362	28	105-TRIAL-G├£CE 123
363	28	19-TRIAL-KE┼ŞAP 281
364	28	22-TRIAL-P─░RAZ─░Z 188
365	28	113-TRIAL-┼ŞEB─░NKARAH─░SAR 62
366	28	281-TRIAL-T─░REBOLU 176
367	28	89-TRIAL-YA─ŞLIDERE 262
368	29	28-TRIAL-G├£M├£┼ŞHANE 38
369	29	27-TRIAL-KELK─░T 71
370	29	173-TRIAL-K├ûSE 265
371	29	80-TRIAL-K├£RT├£N 237
372	29	170-TRIAL-┼Ş─░RAN 72
373	29	271-TRIAL-TORUL 4
374	30	91-TRIAL-HAKKAR─░ 282
375	30	293-TRIAL-├çUKURCA 224
376	30	267-TRIAL-┼ŞEMD─░NL─░ 47
377	30	217-TRIAL-Y├£KSEKOVA 160
378	31	160-TRIAL-ANTAKYA 213
379	31	76-TRIAL-ALTIN├ûZ├£ 37
380	31	161-TRIAL-BELEN 38
381	31	169-TRIAL-D├ûRTYOL 67
382	31	153-TRIAL-ERZ─░N 177
383	31	201-TRIAL-HASSA 195
384	31	138-TRIAL-─░SKENDERUN 235
385	31	85-TRIAL-KIRIKHAN 191
386	31	111-TRIAL-KUMLU 232
387	31	288-TRIAL-REYHANLI 296
388	31	297-TRIAL-SAMANDA─Ş 25
389	31	62-TRIAL-YAYLADA─ŞI 30
390	32	104-TRIAL-ISPARTA 273
391	32	237-TRIAL-AKSU 61
392	32	78-TRIAL-ATABEY 175
393	32	263-TRIAL-E─ŞR─░D─░R(E─Ş─░RD─░R) 102
394	32	299-TRIAL-GELENDOST 298
395	32	280-TRIAL-G├ûNEN 71
396	32	143-TRIAL-KE├ç─░BORLU 0
397	32	182-TRIAL-SEN─░RKENT 172
398	32	193-TRIAL-S├£T├ç├£LER 58
399	32	242-TRIAL-┼ŞARK─░KARAA─ŞA├ç 14
400	32	200-TRIAL-ULUBORLU 181
401	32	65-TRIAL-YALVA├ç 229
402	32	291-TRIAL-YEN─░┼ŞARBADEML─░ 153
403	33	175-TRIAL-AKDEN─░Z 133
404	33	116-TRIAL-YEN─░┼ŞEH─░R 154
405	33	271-TRIAL-TOROSLAR 76
406	33	140-TRIAL-MEZ─░TL─░ 171
407	33	79-TRIAL-ANAMUR 171
408	33	53-TRIAL-AYDINCIK 185
409	33	245-TRIAL-BOZYAZI 94
410	33	269-TRIAL-├çAMLIYAYLA 9
411	33	1-TRIAL-ERDEML─░ 245
412	33	152-TRIAL-G├£LNAR (G├£LPINAR) 89
413	33	73-TRIAL-MUT 53
414	33	236-TRIAL-S─░L─░FKE 77
415	33	15-TRIAL-TARSUS 14
416	34	87-TRIAL-BAKIRK├ûY 256
417	34	218-TRIAL-BAYRAMPA┼ŞA 9
418	34	200-TRIAL-BE┼Ş─░KTA┼Ş 264
419	34	67-TRIAL-BEYO─ŞLU 177
420	34	206-TRIAL-ARNAVUTK├ûY 66
421	34	229-TRIAL-EY├£P 274
422	34	197-TRIAL-FAT─░H 83
423	34	91-TRIAL-GAZ─░OSMANPA┼ŞA 103
424	34	114-TRIAL-KA─ŞITHANE 272
425	34	169-TRIAL-K├£├ç├£K├çEKMECE 232
426	34	297-TRIAL-SARIYER 51
427	34	82-TRIAL-┼Ş─░┼ŞL─░ 150
428	34	4-TRIAL-ZEYT─░NBURNU 10
429	34	249-TRIAL-AVCILAR 66
430	34	3-TRIAL-G├£NG├ûREN 155
431	34	57-TRIAL-BAH├çEL─░EVLER 223
432	34	203-TRIAL-BA─ŞCILAR 269
433	34	77-TRIAL-ESENLER 104
434	34	44-TRIAL-BA┼ŞAK┼ŞEH─░R 74
435	34	128-TRIAL-BEYL─░KD├£Z├£ 17
436	34	286-TRIAL-ESENYURT 162
437	34	29-TRIAL-SULTANGAZ─░ 72
438	34	289-TRIAL-ADALAR 91
439	34	222-TRIAL-BEYKOZ 131
440	34	83-TRIAL-KADIK├ûY 21
441	34	41-TRIAL-KARTAL 65
442	34	98-TRIAL-PEND─░K 235
443	34	280-TRIAL-├£MRAN─░YE 242
444	34	155-TRIAL-├£SK├£DAR 190
445	34	186-TRIAL-TUZLA 183
446	34	271-TRIAL-MALTEPE 198
447	34	94-TRIAL-ATA┼ŞEH─░R 169
448	34	159-TRIAL-├çEKMEK├ûY 84
449	34	48-TRIAL-SANCAKTEPE 168
450	34	113-TRIAL-B├£Y├£K├çEKMECE 231
452	34	281-TRIAL-S─░L─░VR─░ 133
453	34	221-TRIAL-┼Ş─░LE 266
454	34	249-TRIAL-SULTANBEYL─░ 247
455	35	299-TRIAL-AL─░A─ŞA 237
456	35	289-TRIAL-BAL├çOVA 107
457	35	161-TRIAL-BAYINDIR 255
458	35	241-TRIAL-BORNOVA 14
459	35	94-TRIAL-BUCA 177
460	35	160-TRIAL-├ç─░─ŞL─░ 282
461	35	216-TRIAL-FO├çA 292
462	35	265-TRIAL-GAZ─░EM─░R 146
463	35	289-TRIAL-G├£ZELBAH├çE 244
464	35	33-TRIAL-KAR┼ŞIYAKA 152
465	35	190-TRIAL-KEMALPA┼ŞA 7
466	35	188-TRIAL-KONAK 258
467	35	153-TRIAL-CUMAOVASI(MENDERES) 45
468	35	183-TRIAL-MENEMEN 192
469	35	291-TRIAL-NARLIDERE 137
470	35	133-TRIAL-SEFER─░H─░SAR 216
471	35	194-TRIAL-SEL├çUK 91
472	35	228-TRIAL-TORBALI 63
473	35	251-TRIAL-URLA 116
474	35	114-TRIAL-BAYRAKLI 48
475	35	36-TRIAL-KARABA─ŞLAR 243
476	35	217-TRIAL-BERGAMA 62
477	35	204-TRIAL-BEYDA─Ş 265
478	35	0-TRIAL-├çE┼ŞME 15
479	35	223-TRIAL-D─░K─░L─░ 108
480	35	75-TRIAL-KARABURUN 286
481	35	27-TRIAL-KINIK 239
482	35	165-TRIAL-K─░RAZ 152
483	35	107-TRIAL-├ûDEM─░┼Ş 141
484	35	51-TRIAL-T─░RE 278
485	36	115-TRIAL-KARS 11
486	36	180-TRIAL-AKYAKA 134
487	36	124-TRIAL-ARPA├çAY 39
488	36	103-TRIAL-D─░GOR 213
489	36	101-TRIAL-KA─ŞIZMAN 6
490	36	161-TRIAL-SARIKAMI┼Ş 104
491	36	266-TRIAL-SEL─░M 160
492	36	220-TRIAL-SUSUZ 97
493	37	241-TRIAL-KASTAMONU 287
494	37	11-TRIAL-ABANA 59
495	37	283-TRIAL-A─ŞLI 285
496	37	102-TRIAL-ARA├ç 189
497	37	48-TRIAL-AZDAVAY 202
498	37	164-TRIAL-BOZKURT 216
499	37	148-TRIAL-C─░DE 121
500	37	123-TRIAL-├çATALZEYT─░N 20
501	37	95-TRIAL-DADAY 65
502	37	52-TRIAL-DEVREKAN─░ 76
503	37	116-TRIAL-DO─ŞANYURT 20
504	37	216-TRIAL-HAN├ûN├£(G├ûK├çEA─ŞA├ç) 36
505	37	95-TRIAL-─░HSANGAZ─░ 39
506	37	274-TRIAL-─░NEBOLU 122
507	37	117-TRIAL-K├£RE 116
508	37	202-TRIAL-PINARBA┼ŞI 112
509	37	211-TRIAL-SEYD─░LER 292
510	37	117-TRIAL-┼ŞENPAZAR 81
511	37	69-TRIAL-TA┼ŞK├ûPR├£ 131
512	37	38-TRIAL-TOSYA 86
513	38	96-TRIAL-KOCAS─░NAN 278
514	38	188-TRIAL-MEL─░KGAZ─░ 95
515	38	198-TRIAL-TALAS 168
516	38	129-TRIAL-AKKI┼ŞLA 206
517	38	102-TRIAL-B├£NYAN 228
518	38	95-TRIAL-DEVEL─░ 195
519	38	10-TRIAL-FELAH─░YE 5
520	38	141-TRIAL-HACILAR 104
521	38	243-TRIAL-─░NCESU 38
522	38	200-TRIAL-├ûZVATAN(├çUKUR) 119
523	38	136-TRIAL-PINARBA┼ŞI 128
524	38	3-TRIAL-SARIO─ŞLAN 254
525	38	295-TRIAL-SARIZ 297
526	38	91-TRIAL-TOMARZA 79
527	38	261-TRIAL-YAHYALI 3
528	38	107-TRIAL-YE┼Ş─░LH─░SAR 228
529	39	79-TRIAL-KIRKLAREL─░ 237
530	39	263-TRIAL-BABAESK─░ 108
531	39	28-TRIAL-DEM─░RK├ûY 266
532	39	210-TRIAL-KOF├çAZ 275
533	39	93-TRIAL-L├£LEBURGAZ 70
534	39	78-TRIAL-PEHL─░VANK├ûY 146
535	39	59-TRIAL-PINARH─░SAR 68
536	39	55-TRIAL-V─░ZE 214
537	40	283-TRIAL-KIR┼ŞEH─░R 178
538	40	77-TRIAL-AK├çAKENT 283
539	40	16-TRIAL-AKPINAR 78
540	40	226-TRIAL-BOZTEPE 196
541	40	68-TRIAL-├ç─░├çEKDA─ŞI 3
542	40	229-TRIAL-KAMAN 102
543	40	16-TRIAL-MUCUR 219
544	41	204-TRIAL-─░ZM─░T 188
545	41	269-TRIAL-BA┼Ş─░SKELE 226
546	41	131-TRIAL-├çAYIROVA 148
547	41	151-TRIAL-DARICA 34
548	41	206-TRIAL-D─░LOVASI 131
549	41	26-TRIAL-KARTEPE 253
550	41	185-TRIAL-GEBZE 30
551	41	121-TRIAL-G├ûLC├£K 80
552	41	270-TRIAL-KANDIRA 218
553	41	150-TRIAL-KARAM├£RSEL 117
554	41	223-TRIAL-T├£T├£N├ç─░FTL─░K 209
555	41	23-TRIAL-DER─░NCE 19
556	42	16-TRIAL-KARATAY 33
557	42	234-TRIAL-MERAM 225
558	42	43-TRIAL-SEL├çUKLU 233
559	42	101-TRIAL-AHIRLI 136
560	42	226-TRIAL-AK├ûREN 98
561	42	131-TRIAL-AK┼ŞEH─░R 77
562	42	225-TRIAL-ALTINEK─░N 115
563	42	126-TRIAL-BEY┼ŞEH─░R 286
564	42	229-TRIAL-BOZKIR 199
565	42	151-TRIAL-C─░HANBEYL─░ 247
566	42	224-TRIAL-├çELT─░K 50
567	42	143-TRIAL-├çUMRA 109
568	42	102-TRIAL-DERBENT 91
569	42	173-TRIAL-DEREBUCAK 94
570	42	79-TRIAL-DO─ŞANH─░SAR 102
571	42	75-TRIAL-EM─░RGAZ─░ 64
572	42	86-TRIAL-ERE─ŞL─░ 286
573	42	90-TRIAL-G├£NEYSINIR 58
574	42	265-TRIAL-HAD─░M 100
575	42	264-TRIAL-HALKAPINAR 71
576	42	42-TRIAL-H├£Y├£K 213
577	42	189-TRIAL-ILGIN 70
578	42	193-TRIAL-KADINHANI 148
579	42	21-TRIAL-KARAPINAR 105
580	42	159-TRIAL-KULU 127
581	42	215-TRIAL-SARAY├ûN├£ 42
582	42	186-TRIAL-SEYD─░┼ŞEH─░R 23
583	42	206-TRIAL-TA┼ŞKENT 91
584	42	270-TRIAL-TUZLUK├çU 2
585	42	7-TRIAL-YALIH├£Y├£K 197
586	42	4-TRIAL-YUNAK 174
587	43	64-TRIAL-K├£TAHYA 27
588	43	150-TRIAL-ALTINTA┼Ş 167
589	43	31-TRIAL-ASLANAPA 84
590	43	214-TRIAL-├çAVDARH─░SAR 37
591	43	162-TRIAL-DOMAN─░├ç 110
592	43	22-TRIAL-DUMLUPINAR 177
593	43	197-TRIAL-EMET 169
594	43	206-TRIAL-GED─░Z 164
595	43	288-TRIAL-H─░SARCIK 203
596	43	215-TRIAL-PAZARLAR 286
597	43	255-TRIAL-S─░MAV 209
598	43	85-TRIAL-┼ŞAPHANE 169
599	43	208-TRIAL-TAV┼ŞANLI 226
600	43	132-TRIAL-TUN├çB─░LEK 175
601	44	204-TRIAL-MALATYA 130
602	44	80-TRIAL-AK├çADA─Ş 207
603	44	292-TRIAL-ARAPK─░R 290
604	44	128-TRIAL-ARGUVAN 75
605	44	109-TRIAL-BATTALGAZ─░ 198
606	44	131-TRIAL-DARENDE 82
607	44	230-TRIAL-DO─ŞAN┼ŞEH─░R 35
608	44	6-TRIAL-DO─ŞANYOL 264
609	44	5-TRIAL-HEK─░MHAN 118
610	44	22-TRIAL-KALE 182
611	44	184-TRIAL-KULUNCAK 192
612	44	182-TRIAL-P├ûT├£RGE 177
613	44	9-TRIAL-YAZIHAN 200
614	44	87-TRIAL-YE┼Ş─░LYURT 279
615	45	224-TRIAL-MAN─░SA 282
616	45	78-TRIAL-AHMETL─░ 125
617	45	44-TRIAL-AKH─░SAR 45
618	45	173-TRIAL-ALA┼ŞEH─░R 228
619	45	209-TRIAL-DEM─░RC─░ 64
620	45	78-TRIAL-G├ûLMARMARA 71
621	45	141-TRIAL-G├ûRDES 75
622	45	208-TRIAL-KIRKA─ŞA├ç 51
623	45	184-TRIAL-K├ûPR├£BA┼ŞI 65
624	45	40-TRIAL-KULA 131
625	45	124-TRIAL-SAL─░HL─░ 245
626	45	83-TRIAL-SARIG├ûL 299
627	45	180-TRIAL-SARUHANLI 221
628	45	20-TRIAL-SELEND─░ 216
629	45	40-TRIAL-SOMA 282
630	45	177-TRIAL-TURGUTLU 58
631	46	7-TRIAL-KAHRAMANMARA┼Ş 223
632	46	37-TRIAL-AF┼Ş─░N 24
633	46	168-TRIAL-ANDIRIN 78
634	46	36-TRIAL-├çA─ŞLAYANCER─░T 103
635	46	43-TRIAL-EK─░N├ûZ├£ 24
636	46	55-TRIAL-ELB─░STAN 134
637	46	170-TRIAL-G├ûKSUN 45
638	46	289-TRIAL-NURHAK 1
639	46	249-TRIAL-PAZARCIK 111
640	46	2-TRIAL-T├£RKO─ŞLU 97
641	47	190-TRIAL-MARD─░N 58
642	47	118-TRIAL-DARGE├ç─░T 18
643	47	261-TRIAL-DER─░K 196
644	47	153-TRIAL-KIZILTEPE 150
645	47	105-TRIAL-MAZIDA─ŞI 177
646	47	126-TRIAL-M─░DYAT(ESTEL) 213
647	47	155-TRIAL-NUSAYB─░N 113
648	47	209-TRIAL-├ûMERL─░ 170
649	47	79-TRIAL-SAVUR 281
650	47	41-TRIAL-YE┼Ş─░LL─░ 105
651	48	296-TRIAL-MU─ŞLA 184
652	48	154-TRIAL-BODRUM 41
653	48	236-TRIAL-DALAMAN 283
654	48	142-TRIAL-DAT├çA 159
655	48	228-TRIAL-FETH─░YE 23
656	48	209-TRIAL-KAVAKLIDERE 136
657	48	272-TRIAL-K├ûYCE─Ş─░Z 17
658	48	243-TRIAL-MARMAR─░S 216
659	48	86-TRIAL-M─░LAS 194
660	48	213-TRIAL-ORTACA 247
661	48	91-TRIAL-ULA 148
662	48	28-TRIAL-YATA─ŞAN 261
663	49	46-TRIAL-MU┼Ş 185
664	49	193-TRIAL-BULANIK 80
665	49	42-TRIAL-HASK├ûY 51
666	49	48-TRIAL-KORKUT 281
667	49	86-TRIAL-MALAZG─░RT 151
668	49	76-TRIAL-VARTO 87
669	50	171-TRIAL-NEV┼ŞEH─░R 145
670	50	114-TRIAL-ACIG├ûL 231
671	50	37-TRIAL-AVANOS 280
784	59	36-TRIAL-MALKARA 51
672	50	49-TRIAL-DER─░NKUYU 48
673	50	297-TRIAL-G├£L┼ŞEH─░R 62
674	50	62-TRIAL-HACIBEKTA┼Ş 44
675	50	95-TRIAL-KOZAKLI 91
676	50	199-TRIAL-├£RG├£P 232
677	51	278-TRIAL-N─░─ŞDE 279
678	51	293-TRIAL-ALTUNH─░SAR 25
679	51	232-TRIAL-BOR 33
680	51	95-TRIAL-├çAMARDI 68
681	51	112-TRIAL-├ç─░FTL─░K(├ûZYURT) 238
682	51	237-TRIAL-ULUKI┼ŞLA 252
683	52	276-TRIAL-ORDU 1
684	52	53-TRIAL-AKKU┼Ş 93
685	52	172-TRIAL-AYBASTI 171
686	52	14-TRIAL-├çAMA┼Ş 158
687	52	168-TRIAL-├çATALPINAR 194
688	52	110-TRIAL-├çAYBA┼ŞI 290
689	52	54-TRIAL-FATSA 118
690	52	262-TRIAL-G├ûLK├ûY 28
691	52	268-TRIAL-G├£LYALI 96
692	52	113-TRIAL-G├£RGENTEPE 157
693	52	274-TRIAL-─░K─░ZCE 134
694	52	86-TRIAL-KARAD├£Z(KABAD├£Z) 238
695	52	79-TRIAL-KABATA┼Ş 51
696	52	57-TRIAL-KORGAN 202
697	52	13-TRIAL-KUMRU 207
698	52	71-TRIAL-MESUD─░YE 81
699	52	3-TRIAL-PER┼ŞEMBE 238
700	52	124-TRIAL-ULUBEY 138
701	52	294-TRIAL-├£NYE 286
702	53	67-TRIAL-R─░ZE 126
703	53	94-TRIAL-ARDE┼ŞEN 241
704	53	52-TRIAL-├çAMLIHEM┼Ş─░N 174
705	53	61-TRIAL-├çAYEL─░ 255
706	53	120-TRIAL-DEREPAZARI 97
707	53	138-TRIAL-FINDIKLI 11
708	53	129-TRIAL-G├£NEYSU 293
709	53	120-TRIAL-HEM┼Ş─░N 94
710	53	91-TRIAL-─░K─░ZDERE 4
711	53	297-TRIAL-─░Y─░DERE 265
712	53	88-TRIAL-KALKANDERE 6
713	53	25-TRIAL-PAZAR 3
714	54	3-TRIAL-ADAPAZARI 237
715	54	286-TRIAL-HENDEK 170
716	54	31-TRIAL-AR─░F─░YE 59
717	54	222-TRIAL-ERENLER 192
718	54	146-TRIAL-SERD─░VAN 27
719	54	230-TRIAL-AKYAZI 165
720	54	270-TRIAL-FER─░ZL─░ 171
721	54	32-TRIAL-GEYVE 95
722	54	64-TRIAL-KARAP├£R├çEK 193
723	54	44-TRIAL-KARASU 246
724	54	56-TRIAL-KAYNARCA 273
725	54	111-TRIAL-KOCAAL─░ 153
726	54	248-TRIAL-PAMUKOVA 234
727	54	178-TRIAL-SAPANCA 137
728	54	4-TRIAL-S├û─Ş├£TL├£ 231
729	54	57-TRIAL-TARAKLI 156
730	55	273-TRIAL-ATAKUM 63
731	55	253-TRIAL-─░LKADIM 201
732	55	248-TRIAL-CAN─░K 280
733	55	234-TRIAL-TEKKEK├ûY 110
734	55	286-TRIAL-ALA├çAM 293
735	55	205-TRIAL-ASARCIK 42
736	55	98-TRIAL-AYVACIK 278
737	55	139-TRIAL-BAFRA 140
738	55	242-TRIAL-├çAR┼ŞAMBA 196
739	55	234-TRIAL-HAVZA 135
740	55	137-TRIAL-KAVAK 17
741	55	8-TRIAL-LAD─░K 224
742	55	245-TRIAL-19 MAYIS(BALLICA) 280
743	55	216-TRIAL-SALIPAZARI 289
744	55	221-TRIAL-TERME 49
745	55	216-TRIAL-VEZ─░RK├ûPR├£ 244
746	55	37-TRIAL-YAKAKENT 208
747	56	44-TRIAL-S─░─░RT 235
748	56	92-TRIAL-BAYKAN 120
749	56	240-TRIAL-ERUH 108
750	56	170-TRIAL-KURTALAN 162
751	56	290-TRIAL-PERVAR─░ 212
752	56	202-TRIAL-AYDINLAR 110
753	56	84-TRIAL-┼Ş─░RVAN 212
754	57	290-TRIAL-S─░NOP 293
755	57	209-TRIAL-AYANCIK 16
756	57	58-TRIAL-BOYABAT 71
757	57	233-TRIAL-D─░KMEN 67
758	57	293-TRIAL-DURA─ŞAN 172
759	57	229-TRIAL-ERFELEK 247
760	57	158-TRIAL-GERZE 25
761	57	266-TRIAL-SARAYD├£Z├£ 125
762	57	107-TRIAL-T├£RKEL─░ 32
763	58	280-TRIAL-S─░VAS 208
764	58	79-TRIAL-AKINCILAR 252
765	58	8-TRIAL-ALTINYAYLA 75
766	58	101-TRIAL-D─░VR─░─Ş─░ 85
767	58	269-TRIAL-DO─ŞAN┼ŞAR 215
768	58	91-TRIAL-GEMEREK 280
769	58	265-TRIAL-G├ûLOVA 209
770	58	260-TRIAL-G├£R├£N 245
771	58	139-TRIAL-HAF─░K 92
772	58	101-TRIAL-─░MRANLI 74
773	58	36-TRIAL-KANGAL 191
774	58	258-TRIAL-KOYULH─░SAR 107
775	58	269-TRIAL-SU┼ŞEHR─░ 166
776	58	108-TRIAL-┼ŞARKI┼ŞLA 15
777	58	35-TRIAL-ULA┼Ş 177
778	58	182-TRIAL-YILDIZEL─░ 266
779	58	288-TRIAL-ZARA 88
780	59	261-TRIAL-TEK─░RDA─Ş 107
781	59	268-TRIAL-├çERKEZK├ûY 73
782	59	104-TRIAL-├çORLU 80
783	59	38-TRIAL-HAYRABOLU 223
785	59	174-TRIAL-MARMARAERE─ŞL─░S─░ 249
786	59	195-TRIAL-MURATLI 256
787	59	79-TRIAL-SARAY 231
788	59	155-TRIAL-┼ŞARK├ûY 16
789	60	161-TRIAL-TOKAT 254
790	60	254-TRIAL-ALMUS 296
791	60	238-TRIAL-ARTOVA 1
792	60	63-TRIAL-BA┼Ş├ç─░FTL─░K 162
793	60	180-TRIAL-ERBAA 159
794	60	11-TRIAL-N─░KSAR 15
795	60	244-TRIAL-PAZAR 244
796	60	198-TRIAL-RE┼ŞAD─░YE 142
797	60	278-TRIAL-SULUSARAY 56
798	60	87-TRIAL-TURHAL 176
799	60	138-TRIAL-YE┼Ş─░LYURT 277
800	60	51-TRIAL-Z─░LE 284
801	61	61-TRIAL-TRABZON 199
802	61	188-TRIAL-AK├çAABAT 265
803	61	26-TRIAL-ARAKLI 196
804	61	80-TRIAL-ARS─░N 82
805	61	146-TRIAL-BE┼Ş─░KD├£Z├£ 298
806	61	118-TRIAL-├çAR┼ŞIBA┼ŞI 285
807	61	250-TRIAL-├çAYKARA 206
808	61	219-TRIAL-DERNEKPAZARI 203
809	61	85-TRIAL-D├£ZK├ûY 75
810	61	166-TRIAL-HAYRAT 258
811	61	69-TRIAL-K├ûPR├£BA┼ŞI 106
812	61	145-TRIAL-MA├çKA 268
813	61	26-TRIAL-OF 218
814	61	182-TRIAL-S├£RMENE 176
815	61	20-TRIAL-┼ŞALPAZARI 175
816	61	50-TRIAL-TONYA 259
817	61	244-TRIAL-VAKFIKEB─░R 7
818	61	255-TRIAL-YOMRA 124
819	62	54-TRIAL-TUNCEL─░ 57
820	62	268-TRIAL-├çEM─░┼ŞGEZEK 47
821	62	61-TRIAL-HOZAT 278
822	62	73-TRIAL-MAZG─░RT 298
823	62	160-TRIAL-NAZIM─░YE 268
824	62	76-TRIAL-OVACIK 297
825	62	124-TRIAL-PERTEK 48
826	62	203-TRIAL-P├£L├£M├£R 116
827	63	258-TRIAL-┼ŞANLIURFA 175
828	63	167-TRIAL-AK├çAKALE 290
829	63	258-TRIAL-B─░REC─░K 277
830	63	105-TRIAL-BOZOVA 220
831	63	12-TRIAL-CEYLANPINAR 91
832	63	250-TRIAL-HALFET─░ 47
833	63	230-TRIAL-HARRAN 1
834	63	160-TRIAL-H─░LVAN 90
835	63	250-TRIAL-S─░VEREK 77
836	63	19-TRIAL-SURU├ç 44
837	63	134-TRIAL-V─░RAN┼ŞEH─░R 133
838	64	65-TRIAL-U┼ŞAK 132
839	64	73-TRIAL-BANAZ 239
840	64	170-TRIAL-E┼ŞME 197
841	64	43-TRIAL-KARAHALLI 52
842	64	134-TRIAL-S─░VASLI 216
843	64	56-TRIAL-ULUBEY 248
844	65	164-TRIAL-VAN 136
845	65	152-TRIAL-BAH├çESARAY 260
846	65	123-TRIAL-BA┼ŞKALE 130
847	65	91-TRIAL-├çALDIRAN 23
848	65	7-TRIAL-├çATAK 144
849	65	124-TRIAL-EDREM─░T(G├£M├£┼ŞDERE) 29
850	65	27-TRIAL-ERC─░┼Ş 195
851	65	215-TRIAL-GEVA┼Ş 252
852	65	132-TRIAL-G├£RPINAR 28
853	65	219-TRIAL-MURAD─░YE 117
854	65	152-TRIAL-├ûZALP 191
855	65	0-TRIAL-SARAY 135
856	66	272-TRIAL-YOZGAT 174
857	66	73-TRIAL-AKDA─ŞMADEN─░ 206
858	66	155-TRIAL-AYDINCIK 295
859	66	249-TRIAL-BO─ŞAZLIYAN 219
860	66	104-TRIAL-├çANDIR 89
861	66	80-TRIAL-├çAYIRALAN 246
862	66	293-TRIAL-├çEKEREK 292
863	66	208-TRIAL-KADI┼ŞEHR─░ 73
864	66	109-TRIAL-SARAYKENT 272
865	66	25-TRIAL-SARIKAYA 87
866	66	191-TRIAL-SORGUN 42
867	66	288-TRIAL-┼ŞEFAATL─░ 214
868	66	44-TRIAL-YEN─░FAKILI 12
869	66	6-TRIAL-YERK├ûY 165
870	67	19-TRIAL-ZONGULDAK 150
871	67	133-TRIAL-ALAPLI 208
872	67	59-TRIAL-├çAYCUMA 297
873	67	279-TRIAL-DEVREK 246
874	67	249-TRIAL-KARADEN─░ZERE─ŞL─░ 193
875	67	35-TRIAL-G├ûK├çEBEY 154
876	68	226-TRIAL-AKSARAY 257
877	68	204-TRIAL-A─ŞA├ç├ûREN 165
878	68	159-TRIAL-ESK─░L 106
879	68	195-TRIAL-G├£LA─ŞA├ç(A─ŞA├çLI) 139
880	68	252-TRIAL-G├£ZELYURT 205
881	68	193-TRIAL-ORTAK├ûY 183
882	68	149-TRIAL-SARIYAH┼Ş─░ 212
883	69	293-TRIAL-BAYBURT 256
884	69	63-TRIAL-AYDINTEPE 267
885	69	270-TRIAL-DEM─░R├ûZ├£ 265
886	70	134-TRIAL-KARAMAN 197
887	70	244-TRIAL-AYRANCI 239
888	70	175-TRIAL-BA┼ŞYAYLA 186
889	70	283-TRIAL-ERMENEK 124
890	70	285-TRIAL-KAZIMKARABEK─░R 125
891	70	193-TRIAL-SARIVEL─░LER 12
892	71	172-TRIAL-KIRIKKALE 42
893	71	222-TRIAL-BAH┼Ş─░L─░ 24
894	71	281-TRIAL-BALI┼ŞEYH 277
895	71	93-TRIAL-├çELEB─░ 155
896	71	199-TRIAL-DEL─░CE 279
897	71	284-TRIAL-KARAKE├ç─░L─░ 145
898	71	45-TRIAL-KESK─░N 24
899	71	194-TRIAL-SULAKYURT 4
900	71	33-TRIAL-YAH┼Ş─░HAN 222
901	72	24-TRIAL-BATMAN 116
902	72	153-TRIAL-BE┼Ş─░R─░ 190
903	72	246-TRIAL-GERC├£┼Ş 174
904	72	104-TRIAL-HASANKEYF 20
905	72	8-TRIAL-KOZLUK 241
906	72	219-TRIAL-SASON 83
907	73	76-TRIAL-┼ŞIRNAK 85
908	73	220-TRIAL-BEYT├£┼Ş┼ŞEBAP 165
909	73	153-TRIAL-C─░ZRE 115
910	73	243-TRIAL-G├£├çL├£KONAK 84
911	73	257-TRIAL-─░D─░L 84
912	73	15-TRIAL-S─░LOP─░ 219
913	73	47-TRIAL-ULUDERE 181
914	74	15-TRIAL-BARTIN 171
915	74	136-TRIAL-AMASRA 19
916	74	166-TRIAL-KURUCA┼Ş─░LE 261
917	74	199-TRIAL-ULUS 236
918	75	283-TRIAL-ARDAHAN 194
919	75	298-TRIAL-├çILDIR 62
920	75	161-TRIAL-DAMAL 172
921	75	131-TRIAL-G├ûLE 79
922	75	95-TRIAL-HANAK 97
923	75	19-TRIAL-POSOF 0
924	76	119-TRIAL-I─ŞDIR 73
925	76	150-TRIAL-ARALIK 114
926	76	44-TRIAL-KARAKOYUNLU 17
927	76	51-TRIAL-TUZLUCA 154
928	77	172-TRIAL-YALOVA 240
929	77	193-TRIAL-ALTINOVA 115
930	77	107-TRIAL-ARMUTLU 289
931	77	142-TRIAL-├ç─░FTL─░KK├ûY 293
932	77	45-TRIAL-├çINARCIK 59
933	77	263-TRIAL-TERMAL 157
934	78	222-TRIAL-KARAB├£K 220
935	78	4-TRIAL-EFLAN─░ 147
936	78	104-TRIAL-ESK─░PAZAR 101
937	78	62-TRIAL-OVACIK 239
938	78	208-TRIAL-SAFRANBOLU 172
939	78	198-TRIAL-YEN─░CE 183
940	79	53-TRIAL-K─░L─░S 272
941	79	223-TRIAL-ELBEYL─░ 145
942	79	141-TRIAL-MUSABEYL─░ 297
943	79	151-TRIAL-POLATEL─░ 161
944	80	242-TRIAL-OSMAN─░YE 83
945	80	162-TRIAL-BAH├çE 288
946	80	196-TRIAL-D├£Z─░├ç─░ 185
947	80	144-TRIAL-HASANBEYL─░ 251
948	80	224-TRIAL-KAD─░RL─░ 16
949	80	240-TRIAL-SUMBAS 225
950	80	148-TRIAL-TOPRAKKALE 10
951	81	49-TRIAL-D├£ZCE 10
952	81	123-TRIAL-AK├çAKOCA 292
953	81	172-TRIAL-CUMAYER─░ 66
954	81	208-TRIAL-├ç─░L─░ML─░ 219
955	81	70-TRIAL-G├ûLYAKA 189
956	81	110-TRIAL-G├£M├£┼ŞOVA 290
957	81	179-TRIAL-KAYNA┼ŞLI 112
958	81	275-TRIAL-YI─ŞILCA 230
\.


--
-- Data for Name: t_doc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_doc (id, doc, description) FROM stdin;
\.


--
-- Data for Name: t_ecotracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_ecotracking (id, company_id, powera, powerb, powerc, date, machine_id) FROM stdin;
10	3391	1.70	1.70	1.70	2016-04-02 11:00:00	67
11	3391	336.20	336.20	336.20	2016-04-02 11:20:00	67
12	3391	361.20	361.20	361.20	2016-04-02 11:30:00	67
13	3391	372.32	372.32	372.32	2016-04-02 11:40:00	67
14	3391	403.09	403.09	403.09	2016-04-02 11:50:00	67
15	3391	403.40	403.40	403.40	2016-04-02 12:00:00	67
16	3391	403.64	403.64	403.64	2016-04-02 12:10:00	67
17	3391	403.27	403.27	403.27	2016-04-02 12:20:00	67
18	3391	402.26	402.26	402.26	2016-04-02 12:30:00	67
19	3391	401.25	401.25	401.25	2016-04-02 12:40:00	67
20	3391	400.00	400.00	400.00	2016-04-02 12:50:00	67
21	3391	393.63	393.63	393.63	2016-04-02 13:00:00	67
22	3391	389.58	389.58	389.58	2016-04-02 13:10:00	67
23	3391	387.00	387.00	387.00	2016-04-02 13:20:00	67
24	3391	383.76	383.76	383.76	2016-04-02 13:30:00	67
25	3391	383.76	383.76	383.76	2016-04-02 13:40:00	67
26	3391	36.20	36.20	36.20	2016-04-02 13:50:00	67
27	3391	1.40	1.40	1.40	2016-04-02 14:00:00	67
9	3391	10.00	10.00	10.00	2016-04-02 11:10:00	67
1	132	220.00	221.00	224.00	2015-03-23 00:00:00	55
2	132	120.15	110.15	109.12	2015-03-22 00:00:00	55
3	132	96.88	56.81	62.63	2015-03-25 00:00:00	55
4	132	291.66	247.85	274.45	2015-03-26 00:00:00	55
6	132	276.90	229.43	249.53	2015-03-27 00:00:00	55
7	132	359.25	314.38	342.63	2015-04-01 00:00:00	55
8	132	358.66	313.78	341.98	2015-04-02 00:00:00	55
\.


--
-- Data for Name: t_eqpmnt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_eqpmnt (id, name, name_tr, active, eqpmnt_type_id) FROM stdin;
1	Casting Equipment	D├Âk├╝m Tezgahlar─▒	1	0
2	Forming Equipment	┼Şekillendirme tezgahlar─▒	1	0
3	Joining Equipment	Birle┼ştirme Tezgahlar─▒	1	0
4	Machining Equipment	Tala┼şl─▒ imalat Tezgahlar─▒	1	0
5	Non-Traditional	Geleneksel Olmayan S├╝re├ğler	1	0
6	testroot5	\N	1	0
7	test2	\N	1	0
\.


--
-- Data for Name: t_eqpmnt_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_eqpmnt_type (id, name, name_tr, mother_id, active) FROM stdin;
1	Centrifugal Casting Machine	Santrif├╝jal D├Âk├╝m 	1	1
2	Die Casting	Press D├Âk├╝m	1	1
3	Evaporative Pattern Casting	Buharl─▒ D├Âk├╝m	1	1
4	Law Pressure Casting	D├╝┼ş├╝k Bas─▒n├ğl─▒ D├Âk├╝m	1	1
5	Permanent Mold Casting	Daimi Kal─▒p D├Âk├╝m	1	1
6	Forge	D├Âvme tezgah─▒	2	1
7	Powder Metallurgy	Toz Metalurjisi	2	1
8	Press	Press	2	1
9	Rolling Machine	Haddeleme	2	1
10	Shearing Machine	Kesme	2	1
11	Extrusion Machine	├çekme	2	1
12	Brazing(at Temperatures over 450┬░C)	Lehimleme (S─▒cakl─▒k > 450┬░C))	3	1
13	Fastening	Ba─şlama	3	1
14	Press Fitting	Bask─▒l─▒ Ge├ğirme	3	1
15	Sintering	Sinterleme	3	1
16	Soldering(at Temperatures Less than 450┬░C)	Lehimleme ( S─▒cakl─▒k < 450┬░C)	3	1
17	Welding	Kaynak	3	1
18	Lathe	Torna	4	1
19	Milling	Freze	4	1
20	Machining Center	─░┼şleme Merkezi	4	1
21	Shaper	┼Şekillendirme	4	1
22	Drilling Machine	Matkap	4	1
23	Broaching Machine	Bro┼şlama- T─▒─ş ├çekme	4	1
24	Countersinking Machine	Hav┼şa Tez.	4	1
25	Gashing Machine	Di┼şli A├ğma Makinesi	4	1
26	Grinding Machine	Ta┼şlama Tez.	4	1
27	Hobbing Machine	Di┼şli Tezgah─▒	4	1
28	Honning Machine	Honlama Tezgah─▒	4	1
29	Router	Router Tezgah─▒	4	1
30	Saw	Testere	4	1
31	Tapping	K─▒lavuz Tezgah─▒	4	1
32	Reaming	Raybalama	4	1
33	planing	Rendeleme	4	1
34	Laser cutting	Laser Kesme	5	1
35	EDM	EDM	5	1
36	Wire EDM	Tel EDM	5	1
37	test	\N	1	1
38	test2	\N	2	1
39	test4	\N	3	1
40	test3	\N	4	1
41	testroot	\N	4	1
42	testroot2	\N	1	1
43	testroot3	\N	1	1
44	testroot4	\N	1	1
45	non-traditional-test	\N	5	1
46	casting equipment1	\N	1	1
47	test2	\N	1	1
48	test4	\N	1	1
49	test use case	\N	1	1
\.


--
-- Data for Name: t_eqpmnt_type_attrbt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_eqpmnt_type_attrbt (id, attribute_name, attribute_name_tr, attribute_value, eqpmnt_type_id, active) FROM stdin;
\.


--
-- Data for Name: t_flow; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_flow (id, name, name_tr, active, flow_family_id) FROM stdin;
4	Brass	Brass	1	3
5	Copper	Copper	1	3
6	Lead	Lead	1	3
7	Zinc	Zinc	1	3
8	Acetone	Acetone	1	2
9	Ketone	Ketone	1	2
10	Acetoin	Acetoin	1	2
11	Ethanol	Ethanol	1	2
12	Peroxide	Peroxide	1	2
14	Cellulose	Cellulose	1	1
57	wood	\N	1	1
59	nuts	\N	1	4
60	steel	\N	1	3
61	titanium	\N	1	3
69	wastewater	\N	1	13
22	tuna	\N	1	2
23	tel	\N	1	3
65	plastic	\N	1	4
66	aluminium	\N	1	3
67	csteel	\N	1	3
78	fuel	\N	1	14
79	Additives	\N	1	5
80	Dust	\N	1	14
81	EmissionToAir	\N	1	4
82	Residues	\N	1	4
83	RecoveredPaper	\N	1	4
85	Paper	\N	1	4
86	Color	\N	1	5
87	Solvents	\N	1	2
88	Newspapers	\N	1	14
89	wastepaper	\N	1	14
90	Municipalwaste	\N	1	4
93	Municipal_waste	\N	1	4
94	concrete	\N	1	14
95	PE	\N	1	23
96	Polysthyrene	\N	1	23
2	Electricity	Electricity	1	4
1	Water	Water	1	4
97	Cement	\N	1	4
98	Natural_gas	\N	1	14
99	Heat	\N	1	4
100	cutting_fluid	\N	1	4
131	arsenic	\N	1	5
103	cuttingfluid	\N	1	14
104	ldpe	\N	1	23
105	electricity	\N	1	4
107	dust	\N	1	3
108	packagingwaste	\N	1	4
112	vesconite	\N	1	23
114	cleaner	\N	1	2
132	printing plate	\N	1	3
117	cuttingoil	\N	1	5
133	used printing plates	\N	1	3
134	fluegas	\N	1	4
137	cuivre	\N	1	3
139	wood pallet	\N	1	1
140	steam	\N	1	24
146	fuel oil	\N	1	24
147	cleaner 2	\N	1	2
148	cooling emulsion	\N	1	13
149	cardboard	\N	1	14
150	plastic foil	\N	1	23
151	sand	\N	1	22
152	special waste	\N	1	2
153	plastic waste	\N	1	23
170	lpg	\N	1	5
177	dissolver	\N	1	5
178	wooden box	\N	1	1
179	synthetic material	\N	1	23
180	box	\N	1	4
181	heat in waste water	\N	1	24
182	heat from cooling system	\N	1	24
184	organic waste	\N	1	4
185	fired clay	\N	1	22
186	phosphate	\N	1	5
187	phosphoric acid	\N	1	5
188	concrete and gravel	\N	1	22
183	lactoserum	\N	1	4
189	detergent	\N	1	5
190	spent cutting fluid	\N	1	13
192	plastic bottles	\N	1	23
196	flatglass	\N	1	22
197	waste glass	\N	1	22
198	spacer	\N	1	23
199	waste spacer	\N	1	23
56	Deneme2	\N	0	4
68	zeynel	\N	0	1
62	aliuminium	\N	0	3
70	flow1compI	\N	0	14
24	test	\N	0	2
25	yeniflow	\N	0	2
71	flow2compI	\N	0	13
73	flow4compI	\N	0	13
74	flow1compG	\N	0	14
75	flow2compG	\N	0	14
76	flow3compG	\N	0	3
77	flow4compG	\N	0	3
123	test21	\N	0	3
124	test32	\N	0	3
34	rule test5	rule test5	0	4
26	rule test	rule test	0	4
28	rule test2	rule test2	0	4
33	rule test4	rule test4	0	4
35	Deneme	\N	0	4
126	test22	\N	0	3
127	test 23	\N	0	4
109	cuttingtools	\N	0	3
128	testtun	\N	0	3
129	test12	\N	0	2
130	tuna gumus	\N	0	2
118	tuna ├ğa─şlar test	\N	0	4
119	tuna caglar gumus	\N	0	4
120	testttttt	\N	0	4
121	b├╝y├╝k flow deneme	\N	0	4
122	b├╝y├╝k	\N	0	4
135	tuna ├ğa─şlar	\N	0	1
154	aluminyum	\N	0	3
143	gravier	\N	0	22
144	eau	\N	0	13
145	hello space	\N	0	2
155	elektrik	\N	0	24
156	galvaniz	\N	0	5
157	kesme s─▒v─▒s─▒	\N	0	5
158	aluminyum tala┼ş	\N	0	3
159	aluminyum hurda	\N	0	3
160	at─▒k ─▒s─▒	\N	0	24
161	ka─ş─▒t at─▒k	\N	0	1
162	duman	\N	0	4
163	asit	\N	0	5
164	at─▒k su	\N	0	5
166	├╝st├╝b├╝	\N	0	4
167	kesim ├╝r├╝n├╝	\N	0	3
168	torna ├╝r├╝n├╝	\N	0	3
169	s─▒cak ┼şekillendirme ├╝r├╝n├╝	\N	0	3
171	s─▒cak d├Âvme ├╝r├╝n├╝	\N	0	3
172	kumlama ├╝r├╝n├╝	\N	0	3
173	di┼ş a├ğma ├╝r├╝n├╝	\N	0	3
174	ambalaj	\N	0	4
175	light	\N	0	4
176	lightening	\N	0	4
141	huile vegetale	\N	0	5
191	malt	\N	0	14
193	fructose	\N	0	14
194	concentrate	\N	0	13
195	glass bottle	\N	0	14
84	WoodChips	\N	1	1
200	safety glass	\N	1	22
201	acetylcellulose	\N	1	22
202	paint	\N	1	5
205	oil	\N	1	4
206	sodium hydroxide	\N	1	4
207	cotton filters	\N	1	14
208	carbon	\N	1	4
210	packaging	\N	1	4
213	fat	\N	1	13
214	milk	\N	1	13
216	electricity_lv_rer	\N	1	24
217	water_and_wastewater_ch	\N	1	13
221	phosphoric_acid	\N	1	5
222	sodium_hydroxide	\N	1	5
223	district_heat_mswi	\N	1	24
224	water	\N	1	13
225	rawmilk_losses	\N	1	13
300	Maltcake	\N	1	4
293	Barley grain	\N	1	4
215	raw_milk	\N	1	13
3	Aliminium	Aliminium	0	3
72	flow3compI	\N	0	14
31	rule test3	rule test3	0	4
142	argile	\N	0	22
165	at─▒k ya─ş	\N	0	5
136	ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj	\N	0	2
203	acetone and acetylcellulose solution	\N	0	2
204	electricity to chemical bar	\N	0	24
211	ibi	\N	0	2
212	testflow	\N	0	2
218	awdwad	\N	0	5
220	etetet	\N	0	1
13	WoodChips	Woodcips	1	1
226	electricity_ch	\N	1	24
227	paper	\N	1	4
228	paper_waste	\N	1	4
229	chemical_for_cold_sterlilisation	\N	1	5
230	district_heat_from_waste_incineration_plant	\N	1	24
231	water_at_tap	\N	1	13
232	mainly_from_coal_and_nuclear_power_plants	\N	1	24
233	rawmilk_from_cow_farms	\N	1	4
234	phosphoric_acid_for_cip_cleaning	\N	1	5
235	sodium_hydroxide_for_cip_cleaning	\N	1	5
236	waste_water_with_high_organic_load	\N	1	13
237	halades_pe_15	\N	1	5
238	heat_mswi	\N	1	24
240	electricity_fossil	\N	1	24
241	rawmilk	\N	1	13
242	electricity_mix	\N	1	4
243	sterilisation_chemical	\N	1	5
244	hop	\N	1	4
245	yeast	\N	1	4
248	caustic_soda	\N	1	5
249	district_heat	\N	1	24
250	processed_milk	\N	1	14
251	helades_pe_15	\N	1	5
252	water_for_cold_sterilisation	\N	1	13
253	wastewater_cold_sterilisation	\N	1	13
254	hot_water_for_sterilisation	\N	1	13
255	wastewater_hot_sterilisation	\N	1	13
256	heat_hot_sterilisation	\N	1	24
257	electricity_for_hot_sterilisation	\N	1	24
258	fresh_water	\N	1	4
259	waste_water_general	\N	1	4
260	hot_water_general	\N	1	4
261	refrigerant_r407c	\N	1	5
262	plastic_waste	\N	1	23
263	release_into_air_refrigerant_r407c	\N	1	5
264	petcoke	\N	1	24
265	co2	\N	1	4
266	nitrogen_oxides	\N	1	4
267	ammonia	\N	1	2
268	awdad	\N	1	4
270	TEST	\N	1	\N
282	xTestEPKim	\N	1	\N
292	Electricity from hydro reservoir in alpine region CH high Voltage	\N	1	\N
299	Nutritionswine	\N	1	4
298	nutritivebiomass	\N	1	4
296	Horticultural fleece	\N	1	4
283	Wasterwater treatment CH	\N	1	4
284	Vegetarian meal	\N	1	4
288	Freight transoceanic ship World	\N	1	4
289	Freight train CH	\N	1	4
272	Electricity CH medium Voltage	\N	1	24
290	Heat natural gas CH	\N	1	24
291	Heat natural gas heat and power cogeneration CH	\N	1	24
297	Electricity World medium Voltage	\N	1	24
287	Soybean	\N	1	4
295	Plywood outdoor use	\N	1	4
294	Hydrochloric acid	\N	1	4
286	Cladding	\N	1	4
269	Meal with chicken	\N	1	4
271	Cow milk	\N	1	4
276	Tap water	\N	1	4
279	Waste Water	\N	1	4
285	Freight lorry t	\N	1	4
281	Electricity EU low Voltage	\N	1	24
280	Heat air water heat pump CH	\N	1	24
273	Heat borehole heat pump CH	\N	1	24
277	Raw Milk	\N	1	4
278	Raw Milk Loss	\N	1	4
275	Sodium Hydroxide	\N	1	5
274	Phosphoric acid industrial grade	\N	1	5
301	Wheat grain	\N	1	4
302	Heat from biogas heat and power cogeneration CH	\N	1	24
303	Dionised water	\N	1	13
304	Electricity photovoltaic aSi panel CH low Voltage	\N	1	24
305	Nutritive Biomass	\N	1	4
306	Nucler fuel	\N	1	24
307	Milk	\N	1	13
308	Plywood indoor use	\N	1	1
309	Chromium steel stainless	\N	1	3
310	Electricity from municipal waste incineration CH medium Voltage	\N	1	24
311	Concrete normal	\N	1	4
312	Aluminium primary ingot	\N	1	3
313	Limestone	\N	1	4
314	Aluminium	\N	1	3
315	Heat Natural Gas	\N	1	24
316	Steel chromium	\N	1	3
317	Hardwood	\N	1	1
318	Heat Gas	\N	1	24
319	Wood	\N	1	1
320	Water ukr	\N	1	13
321	Heat natural gas	\N	1	14
322	Petcoke Consumption Baseline	\N	1	4
323	RDF burning	\N	1	14
324	MSW transport	\N	1	14
325	Electricity RDF	\N	1	24
326	District heating	\N	1	24
327	Energy mix swiss	\N	1	24
328	Fresh water	\N	1	13
329	Fresh  waste Water	\N	1	13
330	Fernwrme	\N	1	24
331	Oil heating	\N	1	24
332	Strom	\N	1	24
333	water  ARA	\N	1	13
334	Waste incineration plastic	\N	1	14
335	Phosphoric Acid	\N	1	5
336	Dust emission	\N	1	4
337	NOx Emission	\N	1	4
338	Ammonia	\N	1	5
339	Electricity Dust	\N	1	24
340	Petcoke	\N	1	4
341	NOx	\N	1	4
342	Petcokee	\N	1	4
343	Biogas	\N	1	4
344	Textile cotton based	\N	1	4
345	Palm oil	\N	1	4
346	Sugar from sugarbeet	\N	1	4
347	Carrot	\N	1	4
348	Wasser	\N	1	13
349	Hydrogen peroxide	\N	1	5
350	Soap	\N	1	5
351	Reaktivfarbstoff	\N	1	5
352	Farbstoff	\N	1	5
353	Treber	\N	1	4
354	Incineration of hazardous waste CH	\N	1	\N
\.


--
-- Data for Name: t_flow_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_flow_category (id, name, flow_type_id, active) FROM stdin;
\.


--
-- Data for Name: t_flow_family; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_flow_family (id, name, active) FROM stdin;
1	Woods	1
2	Solvents	1
3	Metals	1
4	Other	1
5	Chemicals	1
13	Fluids	1
14	Other	1
22	Inert material	1
23	Plastics	1
24	Energy	1
25		1
26	test	1
\.


--
-- Data for Name: t_flow_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_flow_log (id, flow_id, creation_date, name, name_tr, active, flow_family_id, log_operation_type) FROM stdin;
1	32	2014-11-28 12:35:49.305	rule test3	rule test3	1	0	0
2	33	2014-11-28 12:52:37.941	rule test4	rule test4	1	0	0
3	26	2014-11-28 13:38:52.138	rule test	rule test	1	0	0
4	28	2014-11-28 13:38:52.138	rule test2	rule test2	1	0	0
5	31	2014-11-28 13:38:52.138	rule test3	rule test3	1	0	0
6	33	2014-11-28 13:38:52.138	rule test4	rule test4	1	0	0
7	26	2014-11-28 13:42:22.278	rule test	rule test	1	4	0
8	28	2014-11-28 13:42:22.278	rule test2	rule test2	1	4	0
9	31	2014-11-28 13:42:22.278	rule test3	rule test3	1	4	0
10	33	2014-11-28 13:42:22.278	rule test4	rule test4	1	4	0
11	26	2014-11-28 14:02:05.905	rule test	rule test	1	0	2
12	28	2014-11-28 14:02:05.905	rule test2	rule test2	1	0	2
13	31	2014-11-28 14:02:05.905	rule test3	rule test3	1	0	2
14	33	2014-11-28 14:02:05.905	rule test4	rule test4	1	0	2
15	34	2014-11-28 14:02:41.231	rule test5	rule test5	1	4	1
16	26	2014-11-28 14:03:41.804	rule test	rule test	1	4	2
17	28	2014-11-28 14:03:41.804	rule test2	rule test2	1	4	2
18	31	2014-11-28 14:03:41.804	rule test3	rule test3	1	4	2
19	33	2014-11-28 14:03:41.804	rule test4	rule test4	1	4	2
20	2	2014-12-02 07:06:13.227	Electricity	Electricity	1	4	2
21	1	2014-12-02 07:06:15.868	Water	Water	1	4	2
22	35	2014-12-12 07:26:16.113	Deneme		1	4	1
23	36	2014-12-12 07:31:58.736	kjsdlkasjdklasjdlasjd		1	4	1
24	37	2014-12-12 07:32:16.332	qwewqqweqw		1	3	1
25	38	2014-12-12 07:33:47.738	rtytrytrytrytrytr		1	3	1
26	39	2014-12-12 07:36:18.45	tewrtrwetrewtt		1	4	1
27	40	2014-12-12 07:41:39.36	hsdasdasd		1	4	1
28	41	2014-12-12 07:44:17.632	xxxxxx		1	4	1
29	43	2014-12-12 07:45:39.385	cccccc		1	4	1
30	44	2014-12-12 07:49:23.283	tttttt		1	3	1
31	45	2014-12-12 07:52:16.831	pppp		1	3	1
32	46	2014-12-12 07:54:05.976	dsfsdfsdfdsf		1	4	1
33	47	2014-12-12 07:57:36.332	gggggg		1	4	1
34	50	2014-12-12 08:04:06.32	lllll		1	4	1
35	51	2014-12-12 08:14:21.876	yyyyyy		1	1	1
36	52	2014-12-12 08:17:37.79	wwwww		1	1	1
37	53	2014-12-12 08:18:55.419	wwwww		1	1	1
38	54	2014-12-12 08:19:38.531	kkkkkk		1	1	1
39	55	2014-12-12 08:26:27.647	qqqqqqq		1	2	1
40	56	2014-12-12 08:49:14.091	Deneme2		1	4	1
41	57	2014-12-16 15:56:54.128	wood		1	1	1
42	59	2014-12-17 10:29:05.598	nuts		1	4	1
43	60	2015-01-07 09:23:43.509	steel		1	3	1
44	61	2015-01-07 09:24:36.05	titanium		1	3	1
45	62	2015-01-07 09:25:38.743	aliuminium		1	3	1
46	65	2015-01-07 15:13:20.289	plastic		1	4	1
47	66	2015-01-07 15:14:20.94	aluminium		1	3	1
48	67	2015-01-08 09:46:25.879	csteel		1	3	1
49	68	2015-02-11 14:46:10.261	zeynel		1	1	1
50	69	2015-02-17 09:02:09.927	wastewater		1	13	1
51	70	2015-02-18 08:58:27.359	flow1compI		1	14	1
52	71	2015-02-18 08:59:06.947	flow2compI		1	13	1
53	72	2015-02-18 08:59:45.331	flow3compI		1	14	1
54	73	2015-02-18 09:00:16.045	flow4compI		1	13	1
55	74	2015-02-18 09:37:09.4	flow1compG		1	14	1
56	75	2015-02-18 09:37:45.129	flow2compG		1	14	1
57	76	2015-02-18 09:38:20.574	flow3compG		1	3	1
58	77	2015-02-18 09:38:45.77	flow4compG		1	3	1
59	78	2015-02-24 16:38:57.548	fuel		1	14	1
60	79	2015-02-24 16:43:27.348	Additives		1	5	1
61	80	2015-02-24 16:44:16.483	Dust		1	14	1
62	81	2015-02-24 16:50:49.425	EmissionToAir		1	4	1
63	82	2015-02-24 16:51:53.793	Residues		1	4	1
64	83	2015-02-24 16:54:14.047	RecoveredPaper		1	4	1
65	84	2015-02-24 16:54:56.732	WoodChips		1	1	1
66	85	2015-02-24 16:56:09.824	Paper		1	4	1
67	86	2015-02-25 09:20:06.676	Color		1	5	1
68	87	2015-02-25 09:24:10.487	Solvents		1	2	1
69	88	2015-02-25 09:25:21.569	Newspapers		1	14	1
70	89	2015-02-25 09:31:13.075	wastepaper		1	14	1
71	90	2015-02-25 09:45:03.023	Municipalwaste		1	4	1
72	93	2015-02-25 09:46:47.27	Municipal_waste		1	4	1
73	94	2015-02-27 09:58:16.817	concrete		1	14	1
74	95	2015-02-27 10:18:58.943	PE		1	23	1
75	96	2015-03-02 08:22:48.796	Polysthyrene		1	23	1
76	97	2015-03-03 13:44:58.94	Cement		1	4	1
77	98	2015-03-20 12:15:13.969	Natural_gas		1	14	1
78	99	2015-03-24 10:48:25.703	Heat		1	4	1
79	100	2015-03-25 21:07:05.082	cutting_fluid		1	4	1
80	103	2015-03-25 21:10:41.555	cuttingfluid		1	14	1
81	104	2015-03-25 21:19:48.354	ldpe		1	23	1
82	105	2015-03-25 21:25:49.779	electricity		1	4	1
83	107	2015-03-25 21:31:15.782	dust		1	3	1
84	108	2015-03-25 21:33:12.296	packagingwaste		1	4	1
85	109	2015-03-25 21:35:45.784	cuttingtools		1	3	1
86	112	2015-03-26 11:29:56.081	vesconite		1	23	1
87	114	2015-03-26 12:51:08.919	cleaner		1	2	1
88	117	2015-03-27 07:40:37.838	cuttingoil		1	5	1
89	118	2015-03-27 11:13:42.157	tuna ├ğa─şlar test		1	4	1
90	119	2015-03-27 11:14:28.79	tuna caglar gumus		1	4	1
91	120	2015-03-27 11:15:06.205	testttttt		1	4	1
92	121	2015-03-27 11:42:37.516	b├╝y├╝k flow deneme		1	4	1
93	122	2015-03-27 11:45:24.11	b├╝y├╝k		1	4	1
94	123	2015-04-09 13:39:59.679	test21		1	3	1
95	124	2015-04-09 13:40:46.439	test32		1	3	1
96	126	2015-04-09 13:41:39.832	test22		1	3	1
97	127	2015-04-09 13:42:21.001	test 23		1	4	1
98	128	2015-04-09 13:48:54.513	testtun		1	3	1
99	129	2015-04-09 13:49:55.742	test12		1	2	1
100	130	2015-04-15 07:26:16.856	tuna gumus		1	2	1
101	131	2015-04-21 07:40:43.434	ars├®nic		1	5	1
102	132	2015-05-06 13:05:14.552	printing plate		1	3	1
103	133	2015-05-06 14:00:09	used printing plates		1	3	1
104	134	2015-05-19 09:06:43.01	fluegas		1	4	1
105	135	2015-05-19 12:24:33.406	tuna ├ğa─şlar		1	1	1
106	136	2015-05-19 12:26:10.563	ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj		1	2	1
107	137	2015-05-19 12:54:39.504	cuivre		1	3	1
108	139	2015-05-19 13:00:27.934	wood pallet		1	1	1
109	140	2015-05-19 13:02:36.592	steam		1	24	1
110	141	2015-05-19 13:16:17.765	huile v├®g├®tale		1	5	1
111	142	2015-05-19 13:20:12.133	argile		1	22	1
112	143	2015-05-19 13:26:09.512	gravier		1	22	1
113	144	2015-05-19 13:26:47.248	eau		1	13	1
114	145	2015-06-10 11:44:16.619	hello space		1	2	1
115	146	2015-07-15 12:48:40.764	fuel oil		1	24	1
116	147	2015-07-15 13:17:57.348	cleaner 2		1	2	1
117	148	2015-07-15 13:19:43.933	cooling emulsion		1	13	1
118	149	2015-07-15 13:32:19.529	cardboard		1	14	1
119	150	2015-07-15 13:41:04.378	plastic foil		1	23	1
120	151	2015-07-15 13:50:32.432	sand		1	22	1
121	152	2015-07-15 13:58:50.384	special waste		1	2	1
122	153	2015-07-15 14:04:26.534	plastic waste		1	23	1
123	131	2015-08-16 16:00:35.431	arsenic		1	5	2
124	154	2015-09-01 07:07:35.454	aluminyum		1	3	1
125	155	2015-09-01 07:08:18.769	elektrik		1	24	1
126	156	2015-09-01 07:10:02.203	galvaniz		1	5	1
127	157	2015-09-01 07:10:58.588	kesme s─▒v─▒s─▒		1	5	1
128	158	2015-09-01 07:15:04.059	aluminyum tala┼ş		1	3	1
129	159	2015-09-01 07:24:10.894	aluminyum hurda		1	3	1
130	160	2015-09-01 07:30:09.287	at─▒k ─▒s─▒		1	24	1
131	161	2015-09-01 07:31:28.629	ka─ş─▒t at─▒k		1	1	1
132	162	2015-09-01 07:32:43.694	duman		1	4	1
133	163	2015-09-01 07:33:46.191	asit		1	5	1
134	164	2015-09-01 07:34:59.79	at─▒k su		1	5	1
135	165	2015-09-01 07:35:56.396	at─▒k ya─ş		1	5	1
136	166	2015-09-01 07:36:58.647	├╝st├╝b├╝		1	4	1
137	167	2015-09-01 07:48:14.3	kesim ├╝r├╝n├╝		1	3	1
138	168	2015-09-01 08:40:34.001	torna ├╝r├╝n├╝		1	3	1
139	169	2015-09-01 08:44:07.245	s─▒cak ┼şekillendirme ├╝r├╝n├╝		1	3	1
140	170	2015-09-01 08:44:57.956	lpg		1	5	1
141	171	2015-09-01 08:46:02.551	s─▒cak d├Âvme ├╝r├╝n├╝		1	3	1
142	172	2015-09-01 08:46:59.746	kumlama ├╝r├╝n├╝		1	3	1
143	173	2015-09-01 08:50:19.44	di┼ş a├ğma ├╝r├╝n├╝		1	3	1
144	174	2015-09-01 08:51:24.328	ambalaj		1	4	1
145	175	2015-09-03 12:25:51.906	light		1	4	1
146	176	2015-09-03 12:45:42.183	lightening		1	4	1
147	177	2015-09-03 12:57:34.185	dissolver		1	5	1
148	178	2015-09-03 13:17:19.204	wooden box		1	1	1
149	179	2015-09-03 13:23:37.63	synthetic material		1	23	1
150	180	2015-09-03 13:59:36.612	box		1	4	1
151	181	2015-09-04 08:42:28.488	heat in waste water		1	24	1
152	182	2015-09-04 08:43:45.698	heat from cooling system		1	24	1
153	183	2015-09-04 08:58:00.654	lactos├®rum		1	4	1
154	184	2015-09-04 09:46:23.536	organic waste		1	4	1
155	185	2015-09-04 12:51:27.806	fired clay		1	22	1
156	186	2015-09-04 13:55:04.623	phosphate		1	5	1
157	187	2015-09-04 15:04:00.439	phosphoric acid		1	5	1
158	188	2015-09-04 15:12:08.787	concrete and gravel		1	22	1
443	183	2015-10-02 12:32:34.693	lactoserum		1	4	2
444	136	2015-10-02 12:33:56.429	ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj		1	2	2
445	141	2015-10-02 12:33:56.429	huile vegetale		1	5	2
446	141	2015-10-02 12:34:07.333	huile vegetale		1	5	2
447	136	2015-10-02 12:34:22.171	ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj		1	2	2
448	189	2016-03-09 16:28:22.149	detergent		1	5	1
449	190	2016-03-11 06:06:03.592	spent cutting fluid		1	13	1
450	191	2016-03-11 13:21:43.937	malt		1	14	1
451	192	2016-03-11 14:09:09.319	plastic bottles		1	23	1
452	193	2016-03-11 14:36:38.836	fructose		1	14	1
453	194	2016-03-11 14:53:08.692	concentrate		1	13	1
454	195	2016-03-11 15:33:25.143	glass bottle		1	14	1
455	196	2016-04-12 11:44:50.984	flatglass		1	22	1
456	197	2016-04-12 12:00:00.224	waste glass		1	22	1
457	198	2016-05-16 12:06:59.365	spacer		1	23	1
458	199	2016-05-16 12:20:30.278	waste spacer		1	23	1
459	200	2016-05-16 20:00:03.874	safety glass		1	22	1
460	201	2016-05-18 11:27:30.419	acetylcellulose		1	22	1
461	202	2016-05-18 14:13:47.994	paint		1	5	1
462	203	2016-05-18 14:30:58.736	acetone and acetylcellulose solution		1	2	1
463	204	2016-05-18 14:39:46.578	electricity to chemical bar		1	24	1
464	205	2016-05-25 13:50:09.005	oil		1	4	1
465	206	2016-05-25 13:53:36.448	sodium hydroxide		1	4	1
466	207	2016-05-25 13:56:10.605	cotton filters		1	14	1
467	208	2016-05-25 20:07:17.01	carbon		1	4	1
468	210	2016-05-25 20:53:28.815	packaging		1	4	1
469	211	2016-09-01 10:37:37.302	ibi		1	2	1
470	212	2018-03-28 13:32:55.718607	testflow		1	2	1
471	213	2018-10-16 11:56:40.800545	fat		1	13	1
472	214	2018-10-22 12:00:57.66608	milk		1	13	1
473	215	2018-12-18 10:47:00.527932	raw_milk		1	14	1
474	216	2018-12-18 10:52:03.827025	electricity_lv_rer		1	24	1
475	217	2018-12-18 11:02:02.407437	water_and_wastewater_ch		1	13	1
476	218	2018-12-18 11:11:29.099436	awdwad		1	5	1
477	220	2018-12-18 11:15:50.797126	etetet		1	1	1
478	221	2018-12-18 11:38:42.516131	phosphoric_acid		1	5	1
479	222	2018-12-18 11:39:47.780343	sodium_hydroxide		1	5	1
480	223	2018-12-18 11:42:51.714274	district_heat_mswi		1	24	1
481	224	2018-12-18 14:15:36.986532	water		1	13	1
482	225	2018-12-19 13:19:16.78774	rawmilk_losses		1	13	1
483	215	2019-01-08 09:05:02.162556	raw_milk		1	13	2
484	215	2019-01-08 09:14:27.160809	raw_milk		0	13	2
485	215	2019-01-09 20:08:42.512329	raw_milk		1	13	2
486	3	2019-01-09 20:09:41.596387	Aliminium	Aliminium	0	3	2
487	56	2019-01-09 20:10:05.560158	Deneme2		0	4	2
488	68	2019-01-09 20:10:18.294361	zeynel		0	1	2
489	62	2019-01-09 20:11:24.454305	aliuminium		0	3	2
490	70	2019-01-09 20:13:10.968592	flow1compI		0	14	2
798	300	2020-11-24 21:16:47.272775	Maltcake		1	4	2
799	293	2020-11-24 21:17:30.251066	Barley grain		1	4	2
494	24	2019-01-09 20:14:53.830155	test		0	2	2
495	25	2019-01-09 20:15:02.516358	yeniflow		0	2	2
496	71	2019-01-09 20:15:28.768162	flow2compI		0	13	2
497	72	2019-01-09 20:15:34.275115	flow3compI		0	14	2
498	73	2019-01-09 20:15:38.218204	flow4compI		0	13	2
499	74	2019-01-09 20:15:47.318585	flow1compG		0	14	2
500	75	2019-01-09 20:15:53.636158	flow2compG		0	14	2
501	76	2019-01-09 20:15:57.076114	flow3compG		0	3	2
502	77	2019-01-09 20:15:59.818235	flow4compG		0	3	2
503	123	2019-01-09 20:16:11.806401	test21		0	3	2
504	124	2019-01-09 20:16:15.460691	test32		0	3	2
505	34	2019-01-09 20:16:38.576515	rule test5	rule test5	0	4	2
506	26	2019-01-09 20:16:42.282111	rule test	rule test	0	4	2
507	28	2019-01-09 20:16:45.496301	rule test2	rule test2	0	4	2
508	31	2019-01-09 20:16:48.878071	rule test3	rule test3	0	4	2
509	33	2019-01-09 20:16:52.862059	rule test4	rule test4	0	4	2
510	35	2019-01-09 20:17:07.057958	Deneme		0	4	2
511	126	2019-01-09 20:17:14.366829	test22		0	3	2
512	127	2019-01-09 20:17:22.486434	test 23		0	4	2
513	109	2019-01-09 20:17:34.798704	cuttingtools		0	3	2
514	128	2019-01-09 20:17:43.376299	testtun		0	3	2
515	129	2019-01-09 20:17:50.182187	test12		0	2	2
516	130	2019-01-09 20:18:01.500904	tuna gumus		0	2	2
517	118	2019-01-09 20:18:16.708125	tuna ├ğa─şlar test		0	4	2
518	119	2019-01-09 20:18:28.456407	tuna caglar gumus		0	4	2
519	120	2019-01-09 20:18:39.169091	testttttt		0	4	2
520	121	2019-01-09 20:18:46.936417	b├╝y├╝k flow deneme		0	4	2
521	122	2019-01-09 20:18:53.00254	b├╝y├╝k		0	4	2
522	135	2019-01-09 20:19:03.848291	tuna ├ğa─şlar		0	1	2
523	154	2019-01-09 20:19:17.504224	aluminyum		0	3	2
524	143	2019-01-09 20:19:39.636757	gravier		0	22	2
525	142	2019-01-09 20:19:44.201833	argile		0	22	2
526	144	2019-01-09 20:19:49.846269	eau		0	13	2
527	145	2019-01-09 20:19:57.682064	hello space		0	2	2
528	155	2019-01-09 20:20:33.111946	elektrik		0	24	2
529	156	2019-01-09 20:20:40.955252	galvaniz		0	5	2
530	157	2019-01-09 20:20:54.998811	kesme s─▒v─▒s─▒		0	5	2
531	158	2019-01-09 20:21:03.582882	aluminyum tala┼ş		0	3	2
532	159	2019-01-09 20:21:11.356326	aluminyum hurda		0	3	2
533	160	2019-01-09 20:21:18.894509	at─▒k ─▒s─▒		0	24	2
534	161	2019-01-09 20:21:26.046852	ka─ş─▒t at─▒k		0	1	2
535	162	2019-01-09 20:21:34.296577	duman		0	4	2
536	163	2019-01-09 20:21:41.925524	asit		0	5	2
537	164	2019-01-09 20:21:52.654579	at─▒k su		0	5	2
538	165	2019-01-09 20:21:59.486564	at─▒k ya─ş		0	5	2
539	166	2019-01-09 20:22:05.850306	├╝st├╝b├╝		0	4	2
540	167	2019-01-09 20:22:12.074531	kesim ├╝r├╝n├╝		0	3	2
541	168	2019-01-09 20:22:20.062466	torna ├╝r├╝n├╝		0	3	2
542	169	2019-01-09 20:22:34.912576	s─▒cak ┼şekillendirme ├╝r├╝n├╝		0	3	2
543	171	2019-01-09 20:22:54.902429	s─▒cak d├Âvme ├╝r├╝n├╝		0	3	2
544	172	2019-01-09 20:23:03.282429	kumlama ├╝r├╝n├╝		0	3	2
545	173	2019-01-09 20:23:16.098662	di┼ş a├ğma ├╝r├╝n├╝		0	3	2
546	174	2019-01-09 20:23:25.180838	ambalaj		0	4	2
547	175	2019-01-09 20:23:33.358941	light		0	4	2
548	176	2019-01-09 20:23:38.016801	lightening		0	4	2
549	136	2019-01-09 20:24:12.31962	ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj		0	2	2
550	141	2019-01-09 20:24:20.42359	huile vegetale		0	5	2
551	191	2019-01-09 20:24:34.627549	malt		0	14	2
552	193	2019-01-09 20:24:58.881161	fructose		0	14	2
553	194	2019-01-09 20:25:06.683505	concentrate		0	13	2
554	195	2019-01-09 20:25:13.795402	glass bottle		0	14	2
555	203	2019-01-09 20:26:08.573604	acetone and acetylcellulose solution		0	2	2
556	204	2019-01-09 20:26:41.663672	electricity to chemical bar		0	24	2
557	211	2019-01-09 20:26:52.0892	ibi		0	2	2
558	212	2019-01-09 20:26:57.065574	testflow		0	2	2
559	218	2019-01-09 20:27:08.240856	awdwad		0	5	2
560	220	2019-01-09 20:27:16.307404	etetet		0	1	2
561	13	2019-01-09 20:28:59.017414	WoodChips	Woodcips	1	1	2
562	84	2019-01-09 20:31:12.65169	WoodChips		0	1	2
563	13	2019-01-09 20:31:12.65169	WoodChips	Woodcips	0	1	2
564	84	2019-01-09 20:31:19.725762	WoodChips		1	1	2
565	13	2019-01-09 20:31:19.725762	WoodChips	Woodcips	1	1	2
566	226	2019-01-22 10:00:10.04255	electricity_ch		1	24	1
567	227	2019-01-22 10:02:04.901571	paper		1	4	1
568	228	2019-01-22 16:11:29.036198	paper_waste		1	4	1
569	229	2019-04-01 15:03:36.933954	chemical_for_cold_sterlilisation		1	5	1
570	230	2019-04-01 15:05:13.272803	district_heat_from_waste_incineration_plant		1	24	1
571	231	2019-04-01 15:08:35.096479	water_at_tap		1	13	1
572	232	2019-04-01 15:09:23.599633	mainly_from_coal_and_nuclear_power_plants		1	24	1
573	233	2019-04-01 15:10:10.950928	rawmilk_from_cow_farms		1	4	1
574	234	2019-04-01 15:11:49.742984	phosphoric_acid_for_cip_cleaning		1	5	1
575	235	2019-04-01 15:12:23.776099	sodium_hydroxide_for_cip_cleaning		1	5	1
576	236	2019-04-01 15:15:02.639658	waste_water_with_high_organic_load		1	13	1
577	237	2019-04-01 15:45:46.379148	halades_pe_15		1	5	1
578	238	2019-04-01 15:55:38.760709	heat_mswi		1	24	1
579	240	2019-04-01 16:03:24.005665	electricity_fossil		1	24	1
580	241	2019-04-01 16:26:26.329187	rawmilk		1	13	1
581	242	2019-04-08 14:43:56.33743	electricity_mix		1	4	1
582	243	2019-04-08 15:43:18.892628	sterilisation_chemical		1	5	1
583	244	2020-02-12 10:50:53.982511	hop		1	4	1
584	245	2020-02-12 10:52:36.921586	yeast		1	4	1
585	248	2020-04-14 12:39:45.721593	caustic_soda		1	5	1
586	249	2020-04-14 13:16:10.062466	district_heat		1	24	1
587	250	2020-04-14 14:49:10.624412	processed_milk		1	14	1
588	251	2020-04-16 11:55:41.27313	helades_pe_15		1	5	1
589	252	2020-04-16 12:04:41.183837	water_for_cold_sterilisation		1	13	1
590	253	2020-04-16 12:27:05.892428	wastewater_cold_sterilisation		1	13	1
591	254	2020-04-17 09:55:18.846723	hot_water_for_sterilisation		1	13	1
592	255	2020-04-17 09:56:42.681339	wastewater_hot_sterilisation		1	13	1
593	256	2020-04-17 10:00:40.619515	heat_hot_sterilisation		1	24	1
594	257	2020-04-17 10:02:45.938776	electricity_for_hot_sterilisation		1	24	1
595	258	2020-04-24 09:21:35.069605	fresh_water		1	4	1
596	259	2020-04-24 09:22:49.295175	waste_water_general		1	4	1
597	260	2020-04-24 09:28:08.070868	hot_water_general		1	4	1
598	261	2020-05-01 09:29:09.704259	refrigerant_r407c		1	5	1
599	262	2020-05-03 10:34:10.539923	plastic_waste		1	23	1
600	263	2020-05-06 12:07:42.037568	release_into_air_refrigerant_r407c		1	5	1
601	264	2020-05-11 16:22:22.157217	petcoke		1	24	1
602	265	2020-05-12 07:55:49.859944	co2		1	4	1
603	266	2020-05-12 08:49:25.503761	nitrogen_oxides		1	4	1
604	267	2020-05-12 12:02:17.699518	ammonia		1	2	1
605	268	2020-07-13 14:21:57.885751	awdad		1	4	1
606	269	2020-07-17 14:06:30.156618	Meal with chicken		1	0	1
607	270	2020-07-17 14:17:43.560765	TEST		1	0	1
608	271	2020-08-18 09:26:23.252928	Cow milk		1	0	1
609	272	2020-08-18 09:32:38.156459	Electricity CH medium Voltage		1	0	1
610	273	2020-08-18 09:34:51.999579	Heat borehole heat pump CH		1	0	1
611	274	2020-08-18 09:35:50.057316	Phosphoric acid industrial grade		1	0	1
612	275	2020-08-18 09:38:57.034121	Sodium Hydroxide		1	0	1
613	276	2020-08-18 09:40:21.097181	Tap water		1	0	1
614	277	2020-08-18 09:42:59.024805	Raw Milk		1	0	1
615	278	2020-08-18 09:44:26.94173	Raw Milk Loss		1	0	1
616	279	2020-08-18 09:55:48.706692	Waste Water		1	0	1
617	280	2020-08-18 15:57:45.194198	Heat air water heat pump CH		1	0	1
618	281	2020-08-18 16:00:09.540114	Electricity EU low Voltage		1	0	1
619	282	2020-08-19 09:50:51.252783	xTestEPKim		1	0	1
620	283	2020-08-19 12:19:01.453391	Wasterwater treatment CH		1	0	1
621	284	2020-08-19 12:22:29.432725	Vegetarian meal		1	0	1
622	285	2020-08-19 12:23:33.655746	Freight lorry t		1	0	1
623	286	2020-08-20 11:14:25.027723	Cladding		1	0	1
624	287	2020-08-21 14:20:04.934066	Soybean		1	0	1
625	288	2020-10-24 17:26:17.808658	Freight transoceanic ship World		1	0	1
626	289	2020-10-24 17:27:15.722127	Freight train CH		1	0	1
627	290	2020-10-29 08:11:34.094099	Heat natural gas CH		1	0	1
628	291	2020-10-29 08:11:41.831583	Heat natural gas heat and power cogeneration CH		1	0	1
629	292	2020-10-29 08:16:16.66373	Electricity from hydro reservoir in alpine region CH high Voltage		1	0	1
630	293	2020-10-29 08:28:06.290565	Barley grain		1	0	1
631	294	2020-10-29 08:38:07.334664	Hydrochloric acid		1	0	1
632	295	2020-10-29 09:08:07.726876	Plywood outdoor use		1	0	1
633	296	2020-10-29 09:54:14.780779	Horticultural fleece		1	0	1
634	297	2020-11-12 16:29:01.398487	Electricity World medium Voltage		1	0	1
635	298	2020-11-19 08:09:04.832597	nutritivebiomass		1	0	1
636	299	2020-11-19 09:17:25.5777	Nutritionswine		1	0	1
637	300	2020-11-19 09:55:54.992518	Maltcake		1	0	1
831	272	2020-11-24 21:21:27.912422	Electricity CH medium Voltage		1	4	2
832	287	2020-11-24 21:21:33.909076	Soybean		1	4	2
833	286	2020-11-24 21:21:38.784474	Cladding		1	4	2
834	284	2020-11-24 21:21:46.067561	Vegetarian meal		1	4	2
835	288	2020-11-24 21:21:53.458907	Freight transoceanic ship World		1	4	2
836	289	2020-11-24 21:21:58.56324	Freight train CH		1	4	2
837	272	2020-11-24 21:22:42.864807	Electricity CH medium Voltage		1	24	2
838	290	2020-11-24 21:22:48.752831	Heat natural gas CH		1	24	2
839	291	2020-11-24 21:22:50.435127	Heat natural gas heat and power cogeneration CH		1	24	2
840	297	2020-11-24 21:23:00.028717	Electricity World medium Voltage		1	24	2
841	287	2020-11-24 21:23:08.428816	Soybean		1	4	2
842	301	2020-11-25 07:46:46.153107	Wheat grain		1	4	1
843	302	2020-11-25 11:03:25.775486	Heat from biogas heat and power cogeneration CH		1	24	1
844	303	2020-11-28 10:37:18.994318	Dionised water		1	13	1
845	304	2020-11-30 09:59:06.785927	Electricity photovoltaic aSi panel CH low Voltage		1	24	1
867	299	2020-12-01 14:19:21.152502	Nutritionswine		1	4	2
868	298	2020-12-01 14:19:26.344356	nutritivebiomass		1	4	2
869	296	2020-12-01 14:19:30.951299	Horticultural fleece		1	4	2
870	295	2020-12-01 14:19:35.224888	Plywood outdoor use		1	4	2
871	294	2020-12-01 14:19:44.188548	Hydrochloric acid		1	4	2
872	286	2020-12-01 14:20:01.144606	Cladding		1	4	2
873	269	2020-12-01 14:20:31.043833	Meal with chicken		1	4	2
874	271	2020-12-01 14:20:45.479514	Cow milk		1	4	2
875	276	2020-12-01 14:20:53.375703	Tap water		1	4	2
876	279	2020-12-01 14:20:59.777869	Waste Water		1	4	2
877	285	2020-12-01 14:21:15.81757	Freight lorry t		1	4	2
879	281	2020-12-01 14:21:43.447516	Electricity EU low Voltage		1	4	2
880	281	2020-12-01 14:22:07.153809	Electricity EU low Voltage		1	24	2
881	280	2020-12-01 14:22:17.674237	Heat air water heat pump CH		1	24	2
882	273	2020-12-01 14:22:26.063792	Heat borehole heat pump CH		1	24	2
883	277	2020-12-01 14:22:51.262107	Raw Milk		1	4	2
884	278	2020-12-01 14:22:54.55426	Raw Milk Loss		1	4	2
885	275	2020-12-01 14:23:43.251742	Sodium Hydroxide		1	5	2
886	274	2020-12-01 14:23:51.267525	Phosphoric acid industrial grade		1	5	2
887	283	2020-12-01 14:24:23.515693	Wasterwater treatment CH		1	4	2
888	305	2020-12-01 20:21:24.195193	Nutritive Biomass		1	4	1
889	306	2021-04-21 06:54:52.717895	Nucler fuel		1	24	1
890	307	2021-04-21 07:25:32.569847	Milk		1	13	1
891	308	2021-04-22 10:29:44.330962	Plywood indoor use		1	1	1
892	309	2021-04-22 11:10:39.766098	Chromium steel stainless		1	3	1
893	310	2021-04-22 13:01:52.003489	Electricity from municipal waste incineration CH medium Voltage		1	24	1
894	311	2021-04-22 13:05:03.251827	Concrete normal		1	4	1
895	312	2021-04-22 13:08:37.838634	Aluminium primary ingot		1	3	1
896	313	2021-04-22 13:23:55.729962	Limestone		1	4	1
897	314	2021-04-22 14:29:39.903002	Aluminium		1	3	1
898	315	2021-04-22 14:32:00.423294	Heat Natural Gas		1	24	1
899	316	2021-04-22 14:38:17.187841	Steel chromium		1	3	1
900	317	2021-04-23 07:52:52.363878	Hardwood		1	1	1
901	318	2021-04-23 14:14:43.417193	Heat Gas		1	24	1
902	319	2021-04-23 14:20:07.159851	Wood		1	1	1
903	320	2021-04-24 05:07:33.735375	Water ukr		1	13	1
904	321	2021-04-26 12:40:01.395647	Heat natural gas		1	14	1
905	322	2021-04-28 06:57:26.611319	Petcoke Consumption Baseline		1	4	1
906	323	2021-04-28 07:01:33.839588	RDF burning		1	14	1
907	324	2021-04-28 07:07:58.189686	MSW transport		1	14	1
908	325	2021-04-28 07:09:42.261972	Electricity RDF		1	24	1
909	326	2021-04-28 07:30:07.015031	District heating		1	24	1
910	327	2021-04-28 07:31:50.288746	Energy mix swiss		1	24	1
911	328	2021-04-28 07:35:30.524328	Fresh water		1	13	1
912	329	2021-04-28 07:38:35.400493	Fresh  waste Water		1	13	1
913	330	2021-04-28 07:43:27.844209	Fernwrme		1	24	1
914	331	2021-04-28 07:43:47.636615	Oil heating		1	24	1
915	332	2021-04-28 07:47:38.836721	Strom		1	24	1
916	333	2021-04-28 07:51:19.186773	water  ARA		1	13	1
917	334	2021-04-28 08:34:31.688418	Waste incineration plastic		1	14	1
918	335	2021-04-28 08:42:32.317923	Phosphoric Acid		1	5	1
919	336	2021-04-28 12:46:47.611334	Dust emission		1	4	1
920	337	2021-04-28 12:49:34.62599	NOx Emission		1	4	1
921	338	2021-05-05 09:07:33.02417	Ammonia		1	5	1
922	339	2021-05-05 09:20:48.081305	Electricity Dust		1	24	1
923	340	2021-05-05 16:00:06.856703	Petcoke		1	4	1
924	341	2021-05-05 16:04:05.305268	NOx		1	4	1
925	342	2021-05-05 16:50:38.235371	Petcokee		1	4	1
926	343	2021-05-19 08:16:50.573069	Biogas		1	4	1
927	344	2021-11-17 17:17:04.861171	Textile cotton based		1	4	1
928	345	2021-12-01 11:36:36.433689	Palm oil		1	4	1
929	346	2021-12-01 11:50:35.390959	Sugar from sugarbeet		1	4	1
930	347	2021-12-01 11:56:54.389523	Carrot		1	4	1
931	348	2021-12-01 16:18:23.75147	Wasser		1	13	1
932	349	2021-12-01 16:38:37.741748	Hydrogen peroxide		1	5	1
933	350	2021-12-01 16:50:02.94874	Soap		1	5	1
934	351	2021-12-01 16:55:18.99458	Reaktivfarbstoff		1	5	1
935	352	2021-12-01 16:58:16.894616	Farbstoff		1	5	1
936	353	2021-12-01 17:01:13.725855	Treber		1	4	1
937	354	2022-09-07 17:18:47.337573	Incineration of hazardous waste CH		1	0	1
\.


--
-- Data for Name: t_flow_total_per_cmpny; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_flow_total_per_cmpny (cmpny_id, "Water", "Electricity", "Aliminium", "Brass", "Copper", "Lead", "Zinc", "Acetone", "Ketone", "Acetoin", "Ethanol", "Peroxide", "WoodCips", "Cellulose", cmpny_name, id, yeniflow, "rule test", "rule test2", "rule test3", "rule test4", "rule test5", "Deneme", "Deneme2", wood, nuts, steel, titanium, aliuminium, plastic, aluminium, csteel, test, zeynel, wastewater, "flow1compI", "flow2compI", "flow3compI", "flow4compI", "flow1compG", "flow2compG", "flow3compG", "flow4compG", fuel, "Additives", "Dust", "EmissionToAir", "Residues", "RecoveredPaper", "WoodChips", "Paper", "Color", "Solvents", "Newspapers", wastepaper, "Municipalwaste", "Municipal_waste", concrete, "PE", "Polysthyrene", "Cement", "Natural_gas", "Heat", cutting_fluid, cuttingfluid, ldpe, electricity, dust, packagingwaste, cuttingtools, vesconite, cleaner, cuttingoil, "tuna ├ğa─şlar test", "tuna caglar gumus", testttttt, "b├╝y├╝k flow deneme", "b├╝y├╝k", test21, test32, test22, "test 23", testtun, test12, "tuna gumus", arsenic, "printing plate", "used printing plates", fluegas, "tuna ├ğa─şlar", "ljs├╝├╝├╝ ├¿├¿├¿slkdfjdlfj", cuivre, "wood pallet", steam, "huile vegetale", argile, gravier, eau, "hello space", "fuel oil", "cleaner 2", "cooling emulsion", cardboard, "plastic foil", sand, "special waste", "plastic waste", aluminyum, elektrik, galvaniz, "kesme s─▒v─▒s─▒", "aluminyum tala┼ş", "aluminyum hurda", "at─▒k ─▒s─▒", "ka─ş─▒t at─▒k", duman, asit, "at─▒k su", "at─▒k ya─ş", "├╝st├╝b├╝", "kesim ├╝r├╝n├╝", "torna ├╝r├╝n├╝", "s─▒cak ┼şekillendirme ├╝r├╝n├╝", lpg, "s─▒cak d├Âvme ├╝r├╝n├╝", "kumlama ├╝r├╝n├╝", "di┼ş a├ğma ├╝r├╝n├╝", ambalaj, light, lightening, dissolver, "wooden box", "synthetic material", box, "heat in waste water", "heat from cooling system", lactoserum, "organic waste", "fired clay", phosphate, "phosphoric acid", "concrete and gravel", detergent, "spent cutting fluid", malt, "plastic bottles", fructose, concentrate, "glass bottle", flatglass, "waste glass", spacer, "waste spacer", "safety glass", acetylcellulose, paint, "acetone and acetylcellulose solution", "electricity to chemical bar", oil, "sodium hydroxide", "cotton filters", carbon, packaging, ibi, testflow, fat, milk, raw_milk, electricity_lv_rer, water_and_wastewater_ch, awdwad, etetet, phosphoric_acid, sodium_hydroxide, district_heat_mswi, water, rawmilk_losses, electricity_ch, paper, paper_waste, chemical_for_cold_sterlilisation, district_heat_from_waste_incineration_plant, water_at_tap, mainly_from_coal_and_nuclear_power_plants, rawmilk_from_cow_farms, phosphoric_acid_for_cip_cleaning, sodium_hydroxide_for_cip_cleaning, waste_water_with_high_organic_load, halades_pe_15, heat_mswi, electricity_fossil, rawmilk, electricity_mix, sterilisation_chemical, hop, yeast, caustic_soda, district_heat, processed_milk, helades_pe_15, water_for_cold_sterilisation, wastewater_cold_sterilisation, hot_water_for_sterilisation, wastewater_hot_sterilisation, heat_hot_sterilisation, electricity_for_hot_sterilisation, fresh_water, waste_water_general, hot_water_general, refrigerant_r407c, plastic_waste, release_into_air_refrigerant_r407c, petcoke, co2, nitrogen_oxides, ammonia, awdad, "Meal with chicken", "TEST", "Cow milk", "Electricity CH medium Voltage", "Heat borehole heat pump CH", "Phosphoric acid industrial grade", "Sodium Hydroxide", "Tap water", "Raw Milk", "Raw Milk Loss", "Waste Water", "Heat air water heat pump CH", "Electricity EU low Voltage", "xTestEPKim", "Wasterwater treatment CH", "Vegetarian meal", "Freight lorry t", "Cladding", "Soybean", "Freight transoceanic ship World", "Freight train CH", "Heat natural gas CH", "Heat natural gas heat and power cogeneration CH", "Electricity from hydro reservoir in alpine region CH high Volta", "Barley grain", "Hydrochloric acid", "Plywood outdoor use", "Horticultural fleece", "Electricity World medium Voltage", nutritivebiomass, "Nutritionswine", "Maltcake", "Wheat grain", "Heat from biogas heat and power cogeneration CH", "Dionised water", "Electricity photovoltaic aSi panel CH low Voltage", "Nutritive Biomass", "Nucler fuel", "Milk", "Plywood indoor use", "Chromium steel stainless", "Electricity from municipal waste incineration CH medium Voltage", "Concrete normal", "Aluminium primary ingot", "Limestone", "Aluminium", "Heat Natural Gas", "Steel chromium", "Hardwood", "Heat Gas", "Wood", "Water ukr", "Heat natural gas", "Petcoke Consumption Baseline", "RDF burning", "MSW transport", "Electricity RDF", "District heating", "Energy mix swiss", "Fresh water", "Fresh  waste Water", "Fernwrme", "Oil heating", "Strom", "water  ARA", "Waste incineration plastic", "Phosphoric Acid", "Dust emission", "NOx Emission", "Ammonia", "Electricity Dust", "Petcoke", "NOx", "Petcokee", "Biogas", "Textile cotton based", "Palm oil", "Sugar from sugarbeet", "Carrot", "Wasser", "Hydrogen peroxide", "Soap", "Reaktivfarbstoff", "Farbstoff", "Treber", "Incineration of hazardous waste CH") FROM stdin;
55	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	BMD SOLAR	56	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
56	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	DAMLA K─░MYA	57	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
57	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	DASA KABLO	58	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
58	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ENERBAY	59	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
59	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	EPTIM	60	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
60	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	GES	61	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
50	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ALPIN	62	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
46	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Aktif ─░leti┼şim	63	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
47	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ARGEN	64	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
48	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ART Elek.	65	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
67	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	LEM	80	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
130	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test Catherine 4 Restaurant	105	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Natural_gas", "flow_properties": { "quantity": "1000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
63	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Acetoin", "flow_properties": { "quantity": "10.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	{ "column_name": "Cellulose", "flow_properties": { "quantity": "0.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	Company E	49	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "steel", "flow_properties": { "quantity": "1400.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "titanium", "flow_properties": { "quantity": "50.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "aliuminium", "flow_properties": { "quantity": "10500.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	{ "column_name": "plastic", "flow_properties": { "quantity": "100.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	{ "column_name": "csteel", "flow_properties": { "quantity": "500.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Ketone", "flow_properties": { "quantity": "12345.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	{ "column_name": "Acetoin", "flow_properties": { "quantity": "125000.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	\N	{ "column_name": "Peroxide", "flow_properties": { "quantity": "27000.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	\N	\N	─░s-Ka Grup	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
91	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company I	42	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "flow1compI", "flow_properties": { "quantity": "50.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "flow2compI", "flow_properties": { "quantity": "60.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "flow3compI", "flow_properties": { "quantity": "70.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "flow4compI", "flow_properties": { "quantity": "80.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Alkatem	19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Do─şu┼ş	22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Alimar	18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
87	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company F	38	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
133	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test catherine 5 sljfkldjf	108	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
110	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test Company tuna	90	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
88	{ "column_name": "Water", "flow_properties": { "quantity": "100.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	{ "column_name": "Copper", "flow_properties": { "quantity": "250.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company G	39	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "flow1compG", "flow_properties": { "quantity": "30.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "flow2compG", "flow_properties": { "quantity": "40.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "flow3compG", "flow_properties": { "quantity": "50.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "flow4compG", "flow_properties": { "quantity": "60.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
132	{ "column_name": "Water", "flow_properties": { "quantity": "1260.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	D─░ZAYN MAK─░NA VE M├£HEND─░SL─░K SAN.T─░C.LTD.┼ŞT─░	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "steel", "flow_properties": { "quantity": "14000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "titanium", "flow_properties": { "quantity": "23.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Natural_gas", "flow_properties": { "quantity": "12000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	{ "column_name": "cuttingfluid", "flow_properties": { "quantity": "30750.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "ldpe", "flow_properties": { "quantity": "12.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "dust", "flow_properties": { "quantity": "100.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "packagingwaste", "flow_properties": { "quantity": "1000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "cuttingtools", "flow_properties": { "quantity": "350.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "vesconite", "flow_properties": { "quantity": "200.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "cleaner", "flow_properties": { "quantity": "1.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "cuttingoil", "flow_properties": { "quantity": "1845.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
36	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company B	74	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
37	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company B	75	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
39	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company Ostim A	69	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test Company	77	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
65	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Givaudan	78	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
123	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rpm1	98	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
92	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	tuna test	43	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Argemet Med.	8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Geotek Med.	13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	├çesan	21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
90	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test com	41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ekol San.	12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
122	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	RPM	97	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	An-tek end.	10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
78	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	New company test	29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Enermak	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
75	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test company2	26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
86	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new company test tuna	37	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	BNT Makina	11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	─░ldam	14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
76	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test company3 for IS issue	27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
97	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test of Catherine 3 Waste incineration	87	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Municipalwaste", "flow_properties": { "quantity": "150000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	{ "column_name": "Heat", "flow_properties": { "quantity": "10000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
49	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ASA┼Ş	66	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
95	{ "column_name": "Water", "flow_properties": { "quantity": "1095.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	{ "column_name": "Brass", "flow_properties": { "quantity": "800.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "Copper", "flow_properties": { "quantity": "1400.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	HLS	85	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "steel", "flow_properties": { "quantity": "200000.00", "unit": "mg", "quality": "160t to 180t cuttings and 500kg to 1200kg/piece of heavy rolls", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Residues", "flow_properties": { "quantity": "5000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	{ "column_name": "Solvents", "flow_properties": { "quantity": "600.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	{ "column_name": "Municipalwaste", "flow_properties": { "quantity": "18500.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	{ "column_name": "Heat", "flow_properties": { "quantity": "83500.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "cleaner", "flow_properties": { "quantity": "400.00", "unit": "mg", "quality": "Mix Nitro diluter", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "cleaner 2", "flow_properties": { "quantity": "80.00", "unit": "mg", "quality": "Mix Nitro diluter", "flow_type": "Input" } }	{ "column_name": "cooling emulsion", "flow_properties": { "quantity": "1200.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	{ "column_name": "sand", "flow_properties": { "quantity": "16000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "special waste", "flow_properties": { "quantity": "14200.00", "unit": "mg", "quality": "Cooling emulsion", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "light", "flow_properties": { "quantity": "4000.00", "unit": "mg", "quality": "Metal-halide lamp", "flow_type": "Input" } }	{ "column_name": "lightening", "flow_properties": { "quantity": "6721.00", "unit": "mg", "quality": "Neon tube", "flow_type": "Input" } }	\N	{ "column_name": "wooden box", "flow_properties": { "quantity": "1200.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "synthetic material", "flow_properties": { "quantity": "200.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
96	\N	\N	{ "column_name": "Aliminium", "flow_properties": { "quantity": "50.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test of Catherine 2 Printing	86	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Color", "flow_properties": { "quantity": "65000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "Solvents", "flow_properties": { "quantity": "20000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "Newspapers", "flow_properties": { "quantity": "14000000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
111	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test 134	91	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	dikili a.s	72	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
52	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	AREL	53	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
129	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rpm4	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Bil-ser Ltd.	9	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Mespa	15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
44	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Erkap	50	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
62	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company D	48	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "steel", "flow_properties": { "quantity": "14000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "titanium", "flow_properties": { "quantity": "500.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "aliuminium", "flow_properties": { "quantity": "10500.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ADA Savunma Sanayi-Makine	51	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
69	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Consultant Company	68	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Reddit	70	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
35	\N	\N	\N	\N	{ "column_name": "Copper", "flow_properties": { "quantity": "768557.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company A	73	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Company Ostim B	83	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Destek Mak.	20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
125	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	testesttest	100	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
42	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	adasdasd	45	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
43	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	COMPANY TEST 3	46	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
32	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	├ça─şr─▒ Hid.	23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
51	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ANADOLU METALURJ─░	52	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Peroxide", "flow_properties": { "quantity": "27000.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	\N	\N	Aspar	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Peroxide", "flow_properties": { "quantity": "65000.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	\N	\N	Karada─ş Grup	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	\N	\N	{ "column_name": "Aliminium", "flow_properties": { "quantity": "150.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	{ "column_name": "Lead", "flow_properties": { "quantity": "150.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	{ "column_name": "Acetone", "flow_properties": { "quantity": "0", "unit": "", "quality": "", "flow_type": "" } }	\N	{ "column_name": "Acetoin", "flow_properties": { "quantity": "0", "unit": "", "quality": "", "flow_type": "" } }	\N	\N	\N	\N	EMGE CO	71	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
93	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test company4 for IS issue	44	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Additives", "flow_properties": { "quantity": "12.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
53	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ARGES	54	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
54	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	B─░YOTAR	55	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
77	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Pouly	28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
131	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Dizayn Makina	106	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
128	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rpm3	103	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
126	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test after gis2	101	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Ada savunma Sanayi-Makine	17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
61	\N	\N	{ "column_name": "Aliminium", "flow_properties": { "quantity": "10.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "Copper", "flow_properties": { "quantity": "100.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	{ "column_name": "Acetoin", "flow_properties": { "quantity": "150000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	Company C	47	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "nuts", "flow_properties": { "quantity": "10.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
89	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test Company J	40	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
124	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	test after gis	99	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2M Kablo	16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "zeynel", "flow_properties": { "quantity": "1000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
64	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Sofies	67	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
98	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Geneva 1	88	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "concrete", "flow_properties": { "quantity": "450000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "Polysthyrene", "flow_properties": { "quantity": "1000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
45	\N	\N	{ "column_name": "Aliminium", "flow_properties": { "quantity": "11.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Akta┼ş Holding	76	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
13	\N	\N	\N	{ "column_name": "Brass", "flow_properties": { "quantity": "0.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	{ "column_name": "Acetone", "flow_properties": { "quantity": "123.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "Acetoin", "flow_properties": { "quantity": "11.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "Peroxide", "flow_properties": { "quantity": "55000.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	\N	\N	├çetinkaya A.┼Ş	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "aliuminium", "flow_properties": { "quantity": "0.10", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
99	\N	\N	{ "column_name": "Aliminium", "flow_properties": { "quantity": "28000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Geneva 2	89	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "concrete", "flow_properties": { "quantity": "500000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "PE", "flow_properties": { "quantity": "5000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "Cement", "flow_properties": { "quantity": "123.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
11	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Ketone", "flow_properties": { "quantity": "1234.00", "unit": "kg", "quality": "", "flow_type": "" } }	\N	{ "column_name": "Ethanol", "flow_properties": { "quantity": "0", "unit": "", "quality": "", "flow_type": "" } }	{ "column_name": "Peroxide", "flow_properties": { "quantity": "12000.00", "unit": "mg", "quality": "good", "flow_type": "Input" } }	{ "column_name": "WoodCips", "flow_properties": { "quantity": "32111.00", "unit": "mg", "quality": "", "flow_type": "" } }	\N	Ada Kau├ğuk	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "test", "flow_properties": { "quantity": "1000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
68	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Serbeco	81	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "arsenic", "flow_properties": { "quantity": "20.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	\N	\N	\N	{ "column_name": "Brass", "flow_properties": { "quantity": "10.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	{ "column_name": "Acetone", "flow_properties": { "quantity": "11.00", "unit": "mg", "quality": "11", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	Akmepol	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
94	{ "column_name": "Water", "flow_properties": { "quantity": "1440.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Test of Catherine 1	84	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "fuel", "flow_properties": { "quantity": "222222.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	{ "column_name": "Additives", "flow_properties": { "quantity": "7680.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "EmissionToAir", "flow_properties": { "quantity": "85000.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "Residues", "flow_properties": { "quantity": "22984.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	{ "column_name": "RecoveredPaper", "flow_properties": { "quantity": "91000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "hello space", "flow_properties": { "quantity": "212.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	{ "column_name": "Water", "flow_properties": { "quantity": "30000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Peroxide", "flow_properties": { "quantity": "1000.00", "unit": "mg", "quality": "123", "flow_type": "Input" } }	\N	\N	Ostim Teknoloji A.┼Ş.	82	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "test", "flow_properties": { "quantity": "123.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "testttttt", "flow_properties": { "quantity": "1213.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	{ "column_name": "b├╝y├╝k", "flow_properties": { "quantity": "123.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	{ "column_name": "test12", "flow_properties": { "quantity": "123.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
66	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Givaudan	79	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Solvents", "flow_properties": { "quantity": "100.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "phosphate", "flow_properties": { "quantity": "100.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
134	{ "column_name": "Water", "flow_properties": { "quantity": "3200.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Anonymous Print shop	109	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Color", "flow_properties": { "quantity": "284.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "Natural_gas", "flow_properties": { "quantity": "640000.00", "unit": "mg", "quality": "", "flow_type": "Input" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	{ "column_name": "printing plate", "flow_properties": { "quantity": "38624.00", "unit": "mg", "quality": "0", "flow_type": "Input" } }	{ "column_name": "used printing plates", "flow_properties": { "quantity": "38624.00", "unit": "mg", "quality": "", "flow_type": "Output" } }	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: t_flow_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_flow_type (id, name, name_tr, active) FROM stdin;
1	Input	Input	1
2	Output	Output	1
\.


--
-- Data for Name: t_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_group (id, name, active) FROM stdin;
\.


--
-- Data for Name: t_infrastructure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_infrastructure (id, name) FROM stdin;
\.


--
-- Data for Name: t_is_prj; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_is_prj (id, synergy_id, consultant_id, active, prj_date, name, status, prj_id) FROM stdin;
70	1	32	1	2015-05-05 13:45:50.708	evu test	1	25
101	1	1	1	2015-05-13 09:11:00.855	ostim test	3	\N
107	1	1	1	2015-05-22 15:31:53.919	Test scc	2	\N
68	1	8	1	2015-05-05 13:23:07.569	test	2	38
69	1	8	1	2015-05-05 13:25:11.796	test2	3	38
77	1	8	1	2015-05-05 15:04:33.128	test___	2	38
78	1	8	1	2015-05-06 08:16:01.381	test_06_05_2015	3	38
79	3	8	1	2015-05-06 08:16:48.918	test_06_05_2015__2	4	38
80	3	8	1	2015-05-06 08:17:12.452	test_06_05_2015__3	4	38
81	1	8	1	2015-05-06 08:19:05.012	06_05_2015__3	2	38
82	1	8	1	2015-05-06 08:20:32.672	06_05_2015__4	2	38
86	1	8	1	2015-05-07 07:42:01.273	07_05_2015__01	2	38
87	1	8	1	2015-05-07 07:47:29.579	07_05_2015__02	2	38
88	1	8	1	2015-05-07 07:57:15.861	07_05_2015__03	2	38
89	1	8	1	2015-05-07 07:59:16.977	07_05_2015__04	2	38
90	1	8	1	2015-05-07 08:10:42.99	07_05_2015__4	3	38
71	1	32	1	2015-05-05 13:46:36.62	evu test 2	1	25
72	1	32	1	2015-05-05 13:56:30.412	evu test 4	1	25
73	1	32	1	2015-05-05 13:56:36.952	evu test 4	1	25
74	1	32	1	2015-05-05 14:04:34.781	evu test 4	1	25
91	1	8	1	2015-05-07 08:15:46.355	07_05_2015__5	3	38
75	1	32	1	2015-05-05 14:05:13.09	evu test 4	1	25
76	1	32	1	2015-05-05 14:05:59.854	evu test 4	1	25
83	1	32	1	2015-05-07 06:57:41.933	evu test 5	1	25
84	1	32	1	2015-05-07 06:59:19.093	evu test 5	1	25
85	1	32	1	2015-05-07 07:04:23.909	evu test 6	1	25
94	1	32	1	2015-05-07 08:49:09.733	evu test 6	1	25
93	1	8	1	2015-05-07 08:40:06.575	07_05_2015__6	2	38
97	1	8	1	2015-05-08 08:36:30.441	test_08_05_2015__1	2	38
98	1	8	1	2015-05-08 08:45:19.163	test_08_05_2015__2	2	38
99	1	8	1	2015-05-08 08:46:58.002	test_08_05_2015__3	3	38
20	1	8	1	2014-12-04 11:30:42.687	is-ka OStim	\N	38
38	1	8	1	2014-12-24 15:36:05.509	scenario new slim	\N	38
19	1	8	1	2014-12-04 11:26:22.871	is-ka grup test last	\N	38
47	1	8	1	2015-03-07 15:52:55.379	test deneme	\N	38
48	1	8	1	2015-03-07 16:15:14.836	test zeyn new223344	\N	38
49	1	33	1	2015-03-13 07:56:20.672	20150513	\N	25
65	1	33	1	2015-05-05 07:55:18.582	Guillaume_0505	2	25
66	1	33	1	2015-05-05 08:17:26.52	Guillaume_0505_2	2	25
67	1	33	1	2015-05-05 08:37:39.321	Guillaume_0505_3	3	25
92	1	33	1	2015-05-07 08:39:51.966	blablabla	2	25
100	1	33	1	2015-05-12 11:45:05.704	20150512:table1	2	25
102	1	33	1	2015-05-19 13:35:54.37	Geneva_FTI_AluminiumReuseCase	2	25
103	3	33	1	2015-05-19 13:37:07.497	Geneva_FTI_WasteSteamMutualisation	2	25
104	1	33	1	2015-05-19 13:39:13.307	Geneva_FTI_InertMaterialReuse	2	25
105	1	33	1	2015-05-19 13:54:07.037	Geneva_FTI_All_IS	3	25
106	1	33	1	2015-05-20 12:32:44.308	Test Demo	2	25
108	1	33	1	2015-08-17 12:46:16.123	Test_Manuel_IS	1	25
42	1	33	1	2015-02-27 10:01:04.885	20150227_WoodAnd Concrete	\N	25
43	1	33	1	2015-02-27 20:04:01.303	test group	\N	25
45	1	33	1	2015-03-03 14:28:27.982	Last test 03.03 last	\N	25
46	1	33	1	2015-03-04 15:24:46.719	Very last test	\N	25
39	1	33	1	2015-01-12 16:56:48.683	Table1	\N	25
95	1	32	1	2015-05-07 08:49:41.644	evu test 7	1	25
109	1	8	1	2015-08-19 10:26:13.964	scenario name test 17_08_2015	3	25
111	1	32	1	2015-09-18 14:47:27.561	test evu 	1	45
114	1	8	1	2015-10-30 09:00:35.543	test new manual	2	45
115	1	8	1	2015-10-30 09:02:37.687	test automated last	1	45
116	1	8	1	2015-11-06 12:30:51.241	test new 	2	45
120	1	8	1	2015-11-06 13:56:42.575	testnm_dt	2	45
121	1	33	1	2015-11-25 08:11:14.468	Newtest_Cuivre/aluminium	2	45
122	1	33	1	2015-11-25 08:15:54.945	NewTest2	2	45
123	4	33	1	2015-11-25 08:52:53.394	New test 3	2	45
124	1	33	1	2016-01-20 08:27:59.715	20.01.16	3	45
125	1	33	1	2016-05-17 09:12:19.53	Bafu_test	2	45
126	1	33	1	2016-05-17 09:18:38.144	Bafu_test2	2	45
220	1	28	1	2020-12-01 10:27:25.071822	Dirk	2	42102
128	4	33	1	2018-10-22 13:23:36.518017	Test 2018	\N	45
129	1	33	1	2018-10-22 13:28:08.663612	Test 2018 2	\N	45
130	4	48230	1	2018-11-08 20:17:03.607612	Test UNIDO	1	42072
221	1	48263	1	2020-12-01 11:04:06.683053	Treber f├╝r Viehfutter	2	42100
222	1	48263	1	2020-12-01 11:05:58.430404	Viehfutter	2	42100
223	1	48263	1	2020-12-01 11:10:46.763096	Treber f├╝r Proteinriegel	2	42100
224	1	48262	1	2020-12-01 12:52:14.658603	Treber	3	42102
136	1	48230	1	2019-01-16 13:32:58.724234	Example	3	42072
137	1	48230	1	2019-01-16 13:52:12.112077	Example	2	42072
138	1	48230	1	2019-01-16 14:49:43.753385	Example_case	3	42072
169	4	48239	1	2019-05-18 00:21:07.114576	rawmilk	2	42081
170	1	48239	1	2019-05-18 00:28:53.738391	xxx	3	42081
171	1	48242	1	2019-05-20 12:43:01.066233	Scenario1	\N	42086
174	1	28	1	2020-04-17 08:22:45.844113	Milk losses	2	42077
190	1	28	1	2020-11-19 08:32:02.669675	Treber	2	42096
180	1	48250	1	2020-05-13 07:39:44.570888	plastic waste reuse	2	42092
183	1	48247	1	2020-05-14 15:34:29.993706	Feeding calves milk losses	2	42089
184	1	48248	1	2020-08-18 17:14:59.410241	Test_X3	1	42094
185	1	48248	1	2020-10-26 08:35:02.77136	ljh	3	42097
187	1	48262	1	2020-11-12 09:47:11.414619	Treber f├╝r Futter	2	42102
188	3	48262	1	2020-11-12 09:54:05.584041	Treber entsorgen	2	42102
191	1	48262	1	2020-11-19 09:05:46.520185	Treber	\N	42102
198	1	28	1	2020-11-19 10:17:43.717754	Treber 2	2	42098
213	1	48259	1	2020-12-01 08:47:46.122974	Bier Proteinriegel	2	42096
217	1	48258	1	2020-12-01 09:12:53.959133	Treberkuchen f├╝r Proteinrigel	2	42099
218	1	48259	1	2020-12-01 09:32:18.417382	Bierriegel Protein	2	42096
229	1	48260	1	2020-12-01 22:00:08.403078	SchweinischTreber	2	42098
230	1	48260	1	2020-12-01 22:18:47.597178	Abgabe zu viel el. Energie von PV an Brauerei	2	42098
233	1	48257	1	2020-12-02 00:31:27.739647	Protein Riegel	3	42106
234	1	48257	1	2020-12-02 14:32:40.383601	Protein Riegel	3	42106
245	1	48261	1	2020-12-02 19:16:27.712464	Malzr├╝ckstand nutzen	2	42105
247	1	48258	1	2020-12-03 06:45:36.186407	Treber f├╝r Proteinrigel	2	42099
248	4	48258	1	2020-12-03 06:50:43.883855	Proteinrigel aus Treber	2	42099
256	1	28	1	2021-04-26 12:48:24.174342	hrdrockalupor	1	42109
257	1	48269	1	2021-05-19 07:11:42.557644	Plastic hotel	3	42110
258	1	48269	1	2021-05-19 07:17:21.06548	Test	1	42110
259	1	48269	1	2021-05-19 07:17:33.900345	Test	1	42110
260	1	48269	1	2021-05-19 07:20:07.273799	RDF plastic	3	42110
\.


--
-- Data for Name: t_is_prj_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_is_prj_details (id, cmpny_from_id, cmpny_to_id, flow_id, from_quantity, to_quantity, unit_id, is_prj_id, flow_id_to, to_unit_id, to_flow_type_id) FROM stdin;
366	3460	3464	293	38050	40000	\N	220	298	3	1
376	3469	3456	272	100000	55265	\N	230	272	8	1
310	3435	3438	241	580000	300000	\N	169	241	\N	\N
312	3443	3442	241	10000000	100000	\N	171	241	\N	\N
335	3463	3455	298	30	64499	\N	190	298	3	2
329	3451	3452	278	580000	100000	\N	184	278	3	1
330	3452	3453	277	100000	700	\N	185	6	2	1
316	3422	3419	225	100000	580000	\N	174	225	\N	\N
315	3419	3422	225	580000	100000	\N	174	225	\N	\N
409	3472	3474	334	937	1280000	\N	257	323	4	1
311	3435	3438	241	580000	300000	\N	170	241	22	1
363	3457	3464	298	46192	40000	\N	217	298	3	1
336	3463	3460	293	30	38050	\N	191	293	3	2
367	3458	3463	298	38050	30	\N	221	298	3	1
332	3460	3463	293	38050	30	\N	187	293	3	1
410	3472	3474	334	937	1280000	\N	258	80	3	2
31	15	39	12	12345	760	\N	19	\N	\N	\N
32	15	39	12	12345	760	\N	20	\N	\N	\N
64	15	12	12	12345	27000	\N	38	\N	\N	\N
76	15	14	12	12345	65000	\N	43	\N	\N	\N
231	3406	3407	2	14201100	327070	\N	136	2	\N	\N
232	3406	3407	2	14201100	327070	\N	136	2	\N	\N
233	3406	3407	2	14201100	327070	\N	136	2	\N	\N
234	3406	3410	2	14201100	6453	\N	136	2	\N	\N
368	3463	3458	293	30	38050	\N	222	298	3	2
333	3460	3463	293	38050	30	\N	188	293	3	1
407	3478	3477	320	10000000	500000	\N	256	320	\N	\N
408	3481	3478	320	10000000	10000000	\N	256	320	\N	\N
411	3472	3474	334	937	1280000	\N	259	80	3	2
364	3464	3455	298	40000	38050	\N	218	298	3	2
235	3406	3412	2	14201100	4292712	\N	137	2	\N	\N
236	3412	3406	1	43243	57820	\N	137	1	\N	\N
237	3406	3407	1	57820	15555	\N	137	1	\N	\N
369	3464	3458	298	40000	38050	\N	223	298	3	2
379	3464	3459	305	40000	19000	\N	233	305	\N	\N
412	3472	3474	323	80000	1280000	\N	260	323	4	1
238	3406	3412	2	14201100	4292712	\N	138	2	\N	\N
239	3412	3406	2	4292712	14201100	\N	138	2	\N	\N
240	3406	3412	1	57820	43243	\N	138	1	\N	\N
370	3464	3460	298	40000	38050	\N	224	293	3	2
380	3464	3468	305	40000	19000	\N	234	305	\N	\N
151	13	14	12	0	65000	\N	101	\N	\N	\N
149	13	15	10	0	12345	\N	101	\N	\N	\N
150	13	15	12	0	12345	\N	101	\N	\N	\N
75	13	15	12	0	12345	\N	43	\N	\N	\N
170	13	15	10	0	12345	\N	107	\N	\N	\N
63	15	13	12	12345	0	\N	38	\N	\N	\N
80	15	13	10	12345	0	\N	47	\N	\N	\N
81	15	13	10	12345	0	\N	48	\N	\N	\N
83	15	13	12	12345	0	\N	48	\N	\N	\N
113	99	98	57	123	450000	\N	71	\N	\N	\N
114	99	98	57	123	450000	\N	72	\N	\N	\N
115	99	98	57	123	450000	\N	73	\N	\N	\N
116	99	98	57	123	450000	\N	74	\N	\N	\N
117	99	98	57	123	450000	\N	75	\N	\N	\N
118	99	98	57	123	450000	\N	76	\N	\N	\N
129	99	98	57	123	450000	\N	83	\N	\N	\N
130	99	98	57	123	450000	\N	84	\N	\N	\N
131	99	98	57	123	450000	\N	85	\N	\N	\N
72	99	98	57	123	450000	\N	42	\N	\N	\N
73	99	98	94	123	450000	\N	42	\N	\N	\N
141	99	98	57	123	450000	\N	95	\N	\N	\N
79	99	98	57	123	450000	\N	46	\N	\N	\N
84	99	98	57	123	450000	\N	49	\N	\N	\N
107	98	99	57	450000	123	\N	66	\N	\N	\N
108	98	99	57	450000	123	\N	67	\N	\N	\N
109	98	99	94	450000	123	\N	67	\N	\N	\N
112	98	99	57	450000	123	\N	70	\N	\N	\N
70	98	99	57	450000	123	\N	42	\N	\N	\N
71	98	99	94	450000	123	\N	42	\N	\N	\N
138	98	99	57	450000	123	\N	92	\N	\N	\N
140	98	99	57	450000	123	\N	94	\N	\N	\N
148	98	99	57	450000	123	\N	100	\N	\N	\N
78	98	99	57	450000	123	\N	45	\N	\N	\N
85	98	99	57	450000	123	\N	49	\N	\N	\N
105	11	12	12	1000	27000	\N	65	\N	\N	\N
74	11	12	12	1000	27000	\N	43	\N	\N	\N
106	11	13	12	1000	0	\N	65	\N	\N	\N
65	15	11	12	12345	1000	\N	38	\N	\N	\N
82	15	11	12	12345	1000	\N	48	\N	\N	\N
172	13	11	12	0	1000	\N	107	\N	\N	\N
392	3467	3462	301	40000	19000	\N	245	301	\N	\N
323	3448	3447	262	7101	697	\N	180	262	\N	\N
394	3464	3457	305	40000	19200	\N	247	298	3	2
359	3455	3464	298	38050	40000	\N	213	298	3	1
171	10	13	4	11	0	\N	107	\N	\N	\N
104	13	10	4	0	11	\N	65	\N	\N	\N
66	10	7	2	11	123	\N	39	\N	\N	\N
327	3446	3449	225	579063	840	\N	183	225	\N	\N
328	3449	3446	225	840	579063	\N	183	225	\N	\N
196	135	139	137	1	123	\N	121	3	44	1
153	135	136	66	1	2000000	\N	102	\N	\N	\N
157	135	136	139	1	2000000	\N	105	\N	\N	\N
181	3368	3370	99	100	100	\N	111	187	44	1
198	3368	3370	99	100	100	\N	122	99	37	1
159	135	136	66	1	2000000	\N	105	\N	\N	\N
155	137	138	142	100	100	\N	104	\N	\N	\N
173	137	138	142	100	100	\N	108	\N	\N	\N
202	137	138	142	100	100	\N	124	142	\N	\N
203	137	138	142	100	100	\N	124	142	\N	\N
163	135	136	137	1	2000000	\N	105	\N	\N	\N
164	135	136	137	1	2000000	\N	105	\N	\N	\N
161	138	137	142	100	100	\N	105	\N	\N	\N
162	138	137	142	100	100	\N	105	\N	\N	\N
200	138	137	142	100	100	\N	123	142	\N	\N
201	138	137	142	100	100	\N	124	142	\N	\N
204	138	137	142	100	100	\N	124	142	\N	\N
167	135	136	139	1	2000000	\N	105	\N	\N	\N
168	135	136	66	1	2000000	\N	106	\N	\N	\N
180	135	136	66	1	2000000	\N	111	187	44	1
209	135	136	137	1	2000000	\N	125	137	\N	\N
147	66	68	66	100	21500000	\N	99	\N	\N	\N
217	135	3368	140	1	100	\N	129	99	37	1
152	66	136	66	100	2000000	\N	102	\N	\N	\N
160	66	136	66	100	2000000	\N	105	\N	\N	\N
169	66	136	66	100	2000000	\N	106	\N	\N	\N
190	135	3370	66	1	100	\N	116	99	44	1
120	68	66	66	21500000	100	\N	78	\N	\N	\N
122	68	66	66	21500000	100	\N	79	\N	\N	\N
124	68	66	66	21500000	100	\N	80	\N	\N	\N
126	68	66	66	21500000	100	\N	81	\N	\N	\N
127	68	66	66	21500000	100	\N	82	\N	\N	\N
212	135	3370	140	1	100	\N	126	99	37	1
208	135	138	151	1	100	\N	124	151	\N	\N
211	135	138	151	1	100	\N	125	151	\N	\N
154	135	137	140	1	100	\N	103	\N	\N	\N
165	135	137	140	1	100	\N	105	\N	\N	\N
166	135	137	140	1	100	\N	105	\N	\N	\N
343	3456	3465	298	19000	1000000	\N	198	298	3	1
395	3457	3464	298	19200	40000	\N	248	305	3	1
215	135	137	140	1	100	\N	128	140	\N	\N
175	67	68	66	2400	21500000	\N	109	\N	\N	\N
174	67	66	66	2400	100	\N	109	\N	\N	\N
110	68	67	57	21500000	2400	\N	68	\N	\N	\N
111	68	67	57	21500000	2400	\N	69	\N	\N	\N
119	68	67	66	21500000	2400	\N	77	\N	\N	\N
121	68	67	66	21500000	2400	\N	79	\N	\N	\N
123	68	67	66	21500000	2400	\N	80	\N	\N	\N
125	68	67	66	21500000	2400	\N	81	\N	\N	\N
128	68	67	66	21500000	2400	\N	82	\N	\N	\N
132	68	67	57	21500000	2400	\N	86	\N	\N	\N
133	68	67	57	21500000	2400	\N	87	\N	\N	\N
134	68	67	57	21500000	2400	\N	88	\N	\N	\N
135	68	67	57	21500000	2400	\N	89	\N	\N	\N
158	135	66	66	1	100	\N	105	\N	\N	\N
179	135	66	66	1	100	\N	111	187	44	1
193	135	3374	66	1	100	\N	120	187	44	2
189	135	3374	66	1	100	\N	116	187	44	1
188	135	3375	66	1	100	\N	116	188	44	1
191	135	3375	66	1	100	\N	119	188	44	1
207	138	135	151	100	1	\N	124	151	\N	\N
156	66	135	66	100	1	\N	105	\N	\N	\N
136	68	67	57	21500000	2400	\N	90	\N	\N	\N
137	68	67	57	21500000	2400	\N	91	\N	\N	\N
139	68	67	57	21500000	2400	\N	93	\N	\N	\N
143	68	67	57	21500000	2400	\N	97	\N	\N	\N
144	68	67	57	21500000	2400	\N	98	\N	\N	\N
145	68	67	57	21500000	2400	\N	99	\N	\N	\N
146	66	67	66	100	2400	\N	99	\N	\N	\N
182	66	67	66	100	2400	\N	111	187	44	1
187	3369	3368	99	12000000	100	\N	115	99	44	1
197	3369	3368	99	12000000	100	\N	122	99	37	1
186	3369	3374	184	12000000	100	\N	114	187	44	1
210	3369	3378	184	12000000	10000	\N	125	184	\N	\N
214	3369	3378	184	12000000	10000	\N	128	184	\N	\N
199	3372	137	185	200	100	\N	123	185	\N	\N
206	3372	137	185	200	100	\N	124	185	\N	\N
205	137	3372	185	100	200	\N	124	185	\N	\N
375	3465	3456	298	1000000	19000	\N	229	298	3	2
194	135	3373	66	1	100	\N	120	87	44	1
192	135	3373	66	1	100	\N	119	87	44	1
216	135	3373	137	1	100	\N	129	87	44	1
195	135	3372	66	1	200	\N	120	185	44	1
219	3410	3414	1	6453	900	\N	130	1	\N	\N
218	3412	3414	1	43243	900	\N	130	1	\N	\N
220	3415	3414	1	1000	900	\N	130	1	\N	\N
416	3419	3422	225	\N	\N	\N	130	\N	\N	\N
417	3419	3422	225	\N	\N	\N	130	\N	\N	\N
\.


--
-- Data for Name: t_is_prj_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_is_prj_history (id, cmpny_from_id, cmpny_to_id, flow_id, from_quantity, to_quantity, unit_id, is_prj_id, date) FROM stdin;
\.


--
-- Data for Name: t_is_prj_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_is_prj_status (id, name, name_tr, active) FROM stdin;
1	Low Potential	D├╝┼ş├╝k Potansiyel	1
2	High Potential	Y├╝ksek Potansiyel	1
3	Under Implementation	Uygulama A┼şamas─▒nda	1
4	Implemented	Uyguland─▒	1
5	Failure	Ba┼şar─▒s─▒z	1
\.


--
-- Data for Name: t_log_operation_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_log_operation_type (id, operation_type) FROM stdin;
1	INSERT
2	UPDATE
3	DELETE
\.


--
-- Data for Name: t_nace_code; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_nace_code (id, code) FROM stdin;
1	47.11.01
2	47.11.02
3	47.11.03
4	47.19.01
5	47.25.01
6	47.25.03
7	47.26.01
8	47.29.04
9	47.59.13
10	47.59.14
11	47.59.90
12	47.76.01
13	47.78.26
14	47.78.90
15	47.79.90
16	47.89.90
17	47.91.14
18	47.99.10
19	47.99.11
20	47.99.13
21	46.19.01
22	46.49.08
23	46.49.22
24	46.90.01
25	46.90.04
26	23.19.04
27	23.41.02
28	23.41.03
29	23.41.04
30	32.12.06
31	32.13.01
32	32.40.03
33	32.40.04
34	32.40.05
35	32.40.07
36	32.40.08
37	32.40.09
38	32.40.11
39	32.40.90
40	32.99.03
41	32.99.18
42	46.18.01
43	46.19.02
44	46.49.04
45	46.49.05
46	46.49.12
47	46.49.90
48	47.26.02
49	47.64.01
50	47.64.03
51	47.65.01
52	47.78.04
53	47.79.01
54	47.79.05
55	47.89.08
56	47.89.16
57	95.29.90
58	24.41.16
59	24.41.17
60	24.41.18
61	32.11.01
62	32.12.01
63	32.12.04
64	32.12.07
65	46.48.01
66	46.72.03
67	46.76.03
68	47.77.01
69	47.77.02
70	47.77.05
71	95.25.02
72	26.20.01
73	28.23.01
74	28.23.02
75	28.23.03
76	28.23.04
77	28.23.05
78	28.23.06
79	28.23.07
80	28.23.08
81	33.12.18
82	46.14.01
83	46.51.01
84	46.66.01
85	47.41.01
86	47.78.08
87	47.89.17
88	58.21.01
89	58.29.01
90	62.01.01
91	62.02.01
92	62.03.01
93	62.09.01
94	62.09.02
95	95.11.01
96	17.11.08
97	17.12.07
98	17.21.10
99	17.21.11
100	17.21.12
101	17.21.13
102	17.22.02
103	17.22.03
104	17.22.04
105	17.23.04
106	17.23.06
107	17.23.07
108	17.23.08
109	17.23.09
110	17.24.02
111	17.24.03
112	17.29.01
113	17.29.02
114	17.29.03
115	17.29.04
116	23.99.07
117	46.18.04
118	46.49.03
119	46.76.02
120	47.59.12
121	47.62.01
122	20.42.01
123	20.42.02
124	20.42.03
125	20.42.04
126	20.59.06
127	32.91.03
128	32.99.06
129	46.18.02
130	46.45.01
131	46.45.02
132	47.75.01
133	47.89.09
134	96.02.01
135	96.02.02
136	96.02.03
137	96.02.04
138	96.02.05
139	21.10.01
140	21.20.01
141	21.20.02
142	21.20.03
143	21.20.04
144	23.19.06
145	26.60.01
146	32.50.02
147	32.50.03
148	32.50.04
149	32.50.06
150	32.50.07
151	32.50.09
152	32.50.10
153	32.50.11
154	32.50.12
155	32.50.13
156	32.50.90
157	33.20.50
158	46.18.03
159	46.18.05
160	46.46.01
161	46.46.02
162	46.46.03
163	46.46.04
164	47.73.01
165	47.73.02
166	47.74.01
167	10.41.02
168	10.41.05
169	10.41.07
170	10.42.01
171	10.83.04
172	10.84.01
173	10.84.02
174	10.84.03
175	10.84.05
176	10.86.01
177	10.86.02
178	10.86.03
179	10.89.01
180	10.89.02
181	10.89.04
182	10.89.05
183	10.89.06
184	11.01.01
185	11.01.02
186	11.01.03
187	11.02.01
188	11.02.02
189	11.03.01
190	11.04.02
191	11.05.01
192	11.06.01
193	11.07.01
194	11.07.02
195	11.07.03
196	35.30.22
197	46.17.01
198	46.17.03
199	46.17.04
200	46.33.03
201	46.34.01
202	46.34.02
203	46.34.03
204	46.35.01
205	46.36.03
206	46.36.04
207	46.37.01
208	46.37.02
209	46.37.03
210	46.38.03
211	46.38.05
212	46.38.06
213	46.39.01
214	46.39.02
215	46.44.02
216	47.29.02
217	47.29.03
218	47.29.12
219	47.29.90
220	47.78.15
221	47.81.01
222	47.81.05
223	47.81.09
224	47.89.12
225	23.11.01
226	23.12.01
227	23.12.02
228	23.12.03
229	23.12.04
230	23.14.01
231	23.19.01
232	23.19.05
233	23.19.07
234	23.19.08
235	23.19.90
236	46.73.03
237	47.52.04
238	47.89.02
239	01.14.01
240	01.15.01
241	01.16.02
242	01.16.90
243	01.19.01
244	01.19.02
245	01.19.90
246	01.27.02
247	01.27.90
248	01.28.01
249	01.29.01
250	01.30.03
251	01.30.04
252	01.61.01
253	01.61.02
254	01.61.03
255	01.61.04
256	01.61.05
257	01.61.06
258	01.63.01
259	01.63.03
260	01.63.05
261	01.63.07
262	01.63.90
263	01.64.01
264	02.10.02
265	02.10.03
266	02.30.01
267	02.40.03
268	02.40.04
269	02.40.05
270	02.40.06
271	02.40.07
272	12.00.04
273	46.11.01
274	46.21.04
275	46.21.90
276	46.22.01
277	47.76.02
278	47.81.06
279	47.89.04
280	81.30.01
281	81.30.05
282	81.30.90
283	10.31.01
284	10.31.02
285	10.39.07
286	10.41.01
287	10.61.01
288	10.61.02
289	10.61.05
290	10.61.06
291	10.61.07
292	10.61.08
293	10.61.09
294	10.61.10
295	10.62.01
296	10.62.02
297	10.62.04
298	10.62.05
299	10.62.06
300	10.71.02
301	10.73.03
302	46.36.02
303	46.38.04
304	47.24.01
305	47.81.10
306	01.13.17
307	01.13.18
308	01.13.19
309	01.13.20
310	01.13.21
311	01.13.22
312	01.13.23
313	01.21.05
314	01.22.05
315	01.23.02
316	01.24.04
317	01.25.08
318	01.26.02
319	01.26.90
320	01.63.04
321	01.63.06
322	10.32.01
323	10.32.02
324	10.39.01
325	10.39.04
326	10.39.05
327	10.39.90
328	46.17.02
329	46.31.02
330	46.31.03
331	46.31.04
332	46.31.05
333	46.31.06
334	46.31.90
335	47.21.01
336	47.21.02
337	47.21.03
338	47.81.02
339	01.41.31
340	01.43.01
341	01.47.02
342	01.47.03
343	01.49.01
344	01.49.02
345	01.49.03
346	01.49.90
347	01.50.06
348	01.62.01
349	01.62.02
350	03.11.01
351	03.11.02
352	03.12.01
353	03.21.01
354	03.21.02
355	03.22.01
356	03.22.02
357	10.12.04
358	10.20.03
359	10.20.04
360	10.20.05
361	10.20.06
362	10.20.07
363	10.20.08
364	10.41.10
365	10.41.11
366	10.51.01
367	10.51.02
368	10.51.03
369	10.51.04
370	10.51.05
371	10.52.01
372	10.52.02
373	10.91.01
374	10.92.01
375	46.21.01
376	46.33.01
377	46.33.02
378	46.38.01
379	46.38.02
380	46.49.25
381	47.23.01
382	47.29.01
383	47.29.11
384	47.81.04
385	47.81.07
386	47.81.08
387	47.89.06
388	85.10.01
389	85.10.02
390	85.20.06
391	85.20.07
392	85.20.08
393	85.20.09
394	85.31.12
395	85.31.13
396	85.31.14
397	85.31.16
398	85.32.10
399	85.32.11
400	85.32.12
401	85.32.13
402	85.32.14
403	85.32.15
404	85.32.16
405	85.32.90
406	85.41.01
407	85.42.01
408	85.42.03
409	85.51.03
410	85.52.05
411	85.53.01
412	85.59.01
413	85.59.03
414	85.59.05
415	85.59.06
416	85.59.08
417	85.59.09
418	85.59.10
419	85.59.12
420	85.59.15
421	85.59.90
422	85.60.02
423	55.10.02
424	55.10.05
425	55.20.01
426	55.20.03
427	55.20.04
428	55.30.36
429	55.90.01
430	55.90.02
431	55.90.03
432	56.30.04
433	56.30.05
434	10.85.01
435	56.10.01
436	56.10.02
437	56.10.03
438	56.10.04
439	56.10.05
440	56.10.06
441	56.10.07
442	56.10.08
443	56.10.10
444	56.10.14
445	56.10.17
446	56.10.18
447	56.10.19
448	56.21.01
449	56.29.01
450	56.29.03
451	56.29.90
452	56.30.02
453	56.30.03
454	56.30.06
455	56.30.08
456	56.30.90
457	64.11.06
458	64.19.01
459	64.20.19
460	64.30.01
461	64.91.01
462	64.92.01
463	64.92.04
464	64.92.07
465	64.92.08
466	64.99.01
467	64.99.03
468	64.99.08
469	64.99.09
470	64.99.10
471	64.99.90
472	66.11.02
473	66.12.01
474	66.12.04
475	66.12.06
476	66.12.08
477	66.13.01
478	66.19.02
479	66.19.03
480	66.19.04
481	66.19.05
482	66.19.06
483	66.19.90
484	66.30.02
485	69.20.01
486	69.20.02
487	69.20.03
488	69.20.04
489	69.20.05
490	65.11.02
491	65.12.13
492	65.20.01
493	65.30.01
494	66.21.01
495	66.22.01
496	66.22.02
497	66.29.01
498	66.29.90
499	68.10.01
500	68.20.02
501	68.31.01
502	68.31.02
503	68.32.02
504	68.32.03
505	68.32.04
506	49.31.01
507	49.31.04
508	49.31.05
509	49.31.06
510	49.31.90
511	49.32.01
512	49.39.02
513	49.39.03
514	49.39.08
515	52.21.10
516	49.10.01
517	49.39.01
518	49.39.04
519	49.39.90
520	50.10.12
521	50.10.13
522	50.10.14
523	50.10.15
524	50.10.16
525	50.10.90
526	50.30.08
527	50.30.09
528	51.10.01
529	51.10.02
530	51.10.03
531	52.21.09
532	52.21.13
533	79.11.01
534	79.12.01
535	49.20.01
536	49.41.01
537	49.41.02
538	49.41.03
539	49.41.05
540	49.41.06
541	49.41.07
542	49.41.90
543	49.42.01
544	49.50.90
545	50.20.18
546	50.20.19
547	50.20.20
548	50.20.21
549	50.20.22
550	50.20.23
551	50.20.26
552	50.20.27
553	50.20.28
554	50.20.29
555	50.20.90
556	50.20.91
557	50.40.05
558	50.40.07
559	50.40.08
560	51.21.17
561	51.22.02
562	52.21.04
563	52.21.05
564	52.21.07
565	52.21.08
566	52.21.90
567	52.22.06
568	52.22.07
569	52.22.08
570	52.22.10
571	52.22.90
572	52.23.03
573	52.23.04
574	52.23.06
575	52.23.07
576	52.23.90
577	52.29.05
578	52.29.06
579	52.29.07
580	52.29.11
581	52.29.13
582	52.29.14
583	52.29.15
584	52.29.16
585	52.29.17
586	52.29.18
587	52.29.90
588	66.19.07
589	74.90.03
590	52.29.01
591	52.29.02
592	52.29.03
593	52.29.04
594	52.29.09
595	49.32.02
596	49.39.06
597	74.90.01
598	74.90.02
599	77.11.01
600	77.12.01
601	77.21.01
602	77.21.02
603	77.21.04
604	77.21.90
605	77.22.01
606	77.29.01
607	77.29.02
608	77.29.03
609	77.31.01
610	77.32.01
611	77.33.01
612	77.33.02
613	77.33.03
614	77.34.01
615	77.35.01
616	77.39.01
617	77.39.02
618	77.39.03
619	77.39.04
620	77.39.05
621	77.39.06
622	77.39.07
623	77.39.08
624	77.39.10
625	77.39.11
626	77.39.13
627	77.39.90
628	77.40.01
629	82.11.01
630	82.19.01
631	82.99.04
632	82.99.08
633	06.10.01
634	09.10.03
635	46.71.01
636	47.30.01
637	47.30.02
638	47.78.09
639	49.41.08
640	49.41.09
641	49.41.10
642	49.50.01
643	49.50.03
644	50.20.17
645	50.20.24
646	50.20.25
647	50.20.30
648	52.21.12
649	69.10.01
650	69.10.02
651	69.10.03
652	69.10.04
653	69.10.07
654	69.10.08
655	69.10.09
656	70.10.01
657	70.22.02
658	70.22.03
659	74.90.04
660	74.90.90
661	78.10.01
662	78.20.01
663	78.30.03
664	79.90.90
665	80.10.05
666	80.30.04
667	80.30.05
668	81.10.01
669	81.21.01
670	81.22.01
671	81.29.02
672	81.29.03
673	81.29.04
674	81.29.90
675	82.19.03
676	82.30.02
677	82.91.01
678	82.92.01
679	82.92.05
680	82.99.02
681	82.99.05
682	82.99.07
683	82.99.90
684	84.11.41
685	84.11.42
686	84.11.43
687	84.11.44
688	84.11.45
689	84.11.46
690	84.11.47
691	84.11.48
692	84.11.90
693	84.12.11
694	84.12.12
695	84.12.13
696	84.13.11
697	84.13.12
698	84.13.14
699	84.13.15
700	84.13.16
701	84.13.17
702	84.13.18
703	84.21.05
704	84.21.06
705	84.22.05
706	84.22.06
707	84.23.04
708	84.23.05
709	84.23.06
710	84.24.01
711	84.25.01
712	84.25.02
713	84.30.01
714	97.00.10
715	98.10.01
716	98.20.01
717	99.00.15
718	36.00.02
719	36.00.03
720	37.00.01
721	38.11.01
722	38.11.03
723	38.12.01
724	38.21.01
725	38.22.01
726	38.22.02
727	38.31.01
728	38.31.02
729	38.32.01
730	38.32.02
731	39.00.01
732	46.18.06
733	46.77.01
734	46.77.02
735	71.11.01
736	71.11.02
737	71.11.04
738	71.12.01
739	71.12.03
740	71.12.04
741	71.12.05
742	71.12.06
743	71.12.07
744	71.12.08
745	71.12.09
746	71.12.10
747	71.12.11
748	71.12.12
749	71.12.13
853	93.12.04
750	71.12.90
751	71.20.05
752	71.20.07
753	71.20.08
754	71.20.09
755	71.20.10
756	71.20.11
757	71.20.12
758	71.20.13
759	71.20.90
760	72.11.01
761	72.19.01
762	72.20.01
763	74.10.01
764	26.70.11
765	26.70.12
766	26.70.13
767	32.20.21
768	32.20.22
769	32.20.23
770	32.20.24
771	32.20.25
772	32.20.26
773	32.20.27
774	32.20.28
775	32.20.90
776	46.49.06
777	46.49.21
778	47.59.05
779	47.78.06
780	59.11.03
781	59.12.01
782	59.13.02
783	59.14.02
784	59.20.01
785	59.20.02
786	59.20.03
787	59.20.06
788	60.10.09
789	60.20.01
790	63.11.08
791	63.12.01
792	63.91.01
793	63.99.01
794	70.21.01
795	73.11.01
796	73.11.03
797	73.12.02
798	73.20.03
799	74.10.02
800	74.10.03
801	74.30.12
802	74.90.05
803	78.10.04
804	79.90.01
805	79.90.02
806	84.12.14
807	90.01.14
808	90.01.15
809	90.01.16
810	90.01.17
811	90.01.18
812	90.02.11
813	90.03.09
814	90.03.11
815	90.03.12
816	90.04.01
817	91.01.02
818	91.02.01
819	91.03.02
820	91.04.02
821	93.29.05
822	93.29.08
823	94.99.09
824	94.99.16
825	95.29.06
826	32.30.17
827	32.30.18
828	32.30.19
829	32.30.20
830	32.30.21
831	32.40.01
832	32.40.02
833	32.40.06
834	46.49.02
835	46.49.09
836	46.49.26
837	46.49.27
838	47.64.07
839	47.64.90
840	47.78.01
841	47.89.11
842	61.90.05
843	90.01.20
844	90.01.90
845	90.02.12
846	92.00.01
847	92.00.02
848	92.00.03
849	93.11.01
850	93.11.02
851	93.12.01
852	93.12.03
854	93.12.05
855	93.12.06
856	93.12.07
857	93.12.09
858	93.12.90
859	93.13.01
860	93.19.01
861	93.19.02
862	93.19.03
863	93.19.04
864	93.19.05
865	93.19.06
866	93.19.90
867	93.21.01
868	93.29.01
869	93.29.02
870	93.29.03
871	93.29.07
872	93.29.09
873	93.29.10
874	93.29.90
875	94.11.03
876	94.11.04
877	94.11.05
878	94.11.06
879	94.11.90
880	94.12.01
881	94.12.05
882	94.12.90
883	94.20.01
884	94.91.02
885	94.92.02
886	94.99.01
887	94.99.02
888	94.99.03
889	94.99.04
890	94.99.05
891	94.99.08
892	94.99.12
893	94.99.13
894	94.99.14
895	94.99.15
896	94.99.17
897	94.99.18
898	94.99.19
899	94.99.20
900	94.99.21
901	94.99.22
902	94.99.23
903	94.99.24
904	94.99.90
905	95.29.03
906	96.03.01
907	96.04.01
908	96.04.02
909	96.04.03
910	96.09.02
911	96.09.03
912	96.09.04
913	96.09.05
914	96.09.07
915	96.09.08
916	96.09.09
917	96.09.10
918	96.09.12
919	96.09.14
920	96.09.15
921	96.09.18
922	96.09.90
923	18.11.01
924	18.12.01
925	18.12.02
926	18.12.03
927	18.12.04
928	18.12.05
929	18.12.06
930	18.12.07
931	18.13.01
932	18.13.02
933	18.14.01
934	18.20.02
935	18.20.03
936	46.49.11
937	47.61.01
938	47.62.03
939	47.63.01
940	47.79.03
941	47.89.15
942	58.11.01
943	58.11.03
944	58.11.04
945	58.12.01
946	58.13.01
947	58.14.02
948	58.14.03
949	58.14.90
950	58.19.04
951	58.19.90
952	75.00.02
953	75.00.04
954	86.10.04
955	86.10.05
956	86.10.12
957	86.10.13
958	86.21.02
959	86.21.03
960	86.21.04
961	86.21.90
962	86.22.02
963	86.22.05
964	86.22.06
965	86.22.07
966	86.22.90
967	86.23.01
968	86.23.03
969	86.23.05
970	86.90.01
971	86.90.03
972	86.90.04
973	86.90.05
974	86.90.06
975	86.90.07
976	86.90.09
977	86.90.10
978	86.90.14
979	86.90.16
980	86.90.90
981	87.10.01
982	87.20.02
983	87.30.02
984	87.90.03
985	87.90.04
986	87.90.90
987	88.10.02
988	88.91.01
989	88.99.07
990	88.99.08
991	88.99.09
992	14.11.05
993	14.20.04
994	14.20.05
995	15.11.10
996	15.11.11
997	15.11.13
998	15.12.07
999	15.12.08
1000	15.12.09
1001	15.12.12
1002	46.24.01
1003	46.24.02
1004	46.42.04
1005	46.49.01
1006	47.71.03
1007	47.72.02
1008	47.72.05
1009	47.72.90
1010	95.29.07
1011	13.10.03
1012	13.10.05
1013	13.10.06
1014	13.10.08
1015	13.10.09
1016	13.10.10
1017	13.10.12
1018	13.10.13
1019	13.10.14
1020	13.10.15
1021	13.92.06
1022	13.99.04
1023	13.99.06
1024	20.60.01
1025	20.60.02
1026	46.21.05
1027	46.21.06
1028	46.21.07
1029	46.41.04
1030	46.76.01
1031	46.76.90
1032	47.78.16
1033	47.78.30
1034	13.91.01
1035	13.91.02
1036	14.31.01
1037	14.39.01
1038	46.41.03
1039	47.51.02
1040	14.13.04
1041	14.13.05
1042	14.13.06
1043	14.13.07
1044	46.42.01
1045	46.42.05
1046	47.71.04
1047	47.71.07
1048	47.71.08
1049	47.71.10
1050	47.71.12
1051	47.71.90
1052	95.29.02
1053	14.12.07
1054	14.12.08
1055	14.14.01
1056	14.14.02
1057	14.14.03
1058	14.14.04
1059	14.19.01
1060	14.19.07
1061	46.42.03
1062	46.42.06
1063	47.71.01
1064	47.71.02
1065	47.71.05
1066	47.71.09
1067	47.71.11
1068	47.82.01
1069	13.92.01
1070	13.92.02
1071	13.92.03
1072	13.92.04
1073	13.92.10
1074	13.99.02
1075	46.16.04
1076	46.41.01
1077	47.51.05
1078	47.53.01
1079	13.93.01
1080	13.93.02
1081	16.10.05
1082	46.47.02
1083	46.73.21
1084	46.73.23
1085	47.53.02
1086	47.53.03
1087	47.89.18
1088	13.92.09
1089	13.92.11
1090	13.94.02
1091	13.94.03
1092	13.95.01
1093	13.96.02
1094	13.96.03
1095	13.96.04
1096	13.96.05
1097	13.96.07
1098	13.96.08
1099	13.99.03
1100	14.19.04
1101	14.19.05
1102	14.19.08
1103	32.99.01
1104	32.99.02
1105	32.99.07
1106	33.19.01
1107	33.19.02
1108	46.16.03
1109	46.41.02
1110	46.41.05
1111	46.42.07
1112	47.51.03
1113	47.51.04
1114	47.51.90
1115	47.82.02
1116	13.30.01
1117	13.30.02
1118	13.30.03
1119	13.30.04
1120	96.01.01
1121	96.01.02
1122	96.01.03
1123	96.01.04
1124	96.01.05
1125	42.11.01
1126	42.11.02
1127	42.11.03
1128	42.12.01
1129	42.13.01
1130	42.13.02
1131	42.21.01
1132	42.21.02
1133	42.21.03
1134	42.21.05
1135	42.22.01
1136	42.22.02
1137	42.22.04
1138	42.91.01
1139	42.91.02
1140	42.91.03
1141	42.91.04
1142	42.99.03
1143	43.12.01
1144	43.12.02
1145	43.13.01
1146	43.99.02
1147	41.10.02
1148	41.20.02
1149	41.20.04
1150	41.10.01
1151	41.10.03
1152	41.20.01
1153	41.20.03
1154	42.99.01
1155	42.99.02
1156	42.99.04
1157	43.11.01
1158	43.29.05
1159	43.31.01
1160	43.99.01
1161	43.99.03
1162	43.99.04
1163	43.99.05
1164	43.99.07
1165	43.99.11
1166	23.99.01
1167	23.99.02
1168	38.11.02
1169	41.20.05
1170	43.29.03
1171	43.33.01
1172	43.33.02
1173	43.34.01
1174	43.34.02
1175	43.34.03
1176	43.39.01
1177	43.39.02
1178	43.91.01
1179	43.99.06
1180	43.99.08
1181	43.99.10
1182	43.99.13
1183	43.99.14
1184	43.99.15
1185	16.23.01
1186	16.23.02
1187	46.13.01
1188	46.73.06
1189	46.73.07
1190	46.73.08
1191	46.73.09
1192	46.73.13
1193	46.73.14
1194	46.73.16
1195	46.73.18
1196	46.73.19
1197	46.73.22
1198	46.73.90
1199	47.52.05
1200	47.52.11
1201	47.52.17
1202	47.52.18
1203	47.52.20
1204	47.52.22
1205	47.52.90
1206	23.20.16
1207	23.20.17
1208	23.20.18
1209	23.31.01
1210	23.32.01
1211	23.42.01
1212	23.43.01
1213	23.44.01
1214	23.49.01
1215	23.49.02
1216	23.51.01
1217	23.52.01
1218	23.52.02
1219	23.52.03
1220	23.61.01
1221	23.61.02
1222	23.61.03
1223	23.62.01
1224	23.63.01
1225	23.64.01
1226	23.65.02
1227	23.69.01
1228	23.69.02
1229	23.99.04
1230	23.99.05
1231	23.99.09
1232	23.99.90
1233	46.73.05
1234	47.52.01
1235	28.25.03
1236	28.25.04
1237	33.20.45
1238	43.22.01
1239	43.22.03
1240	43.22.05
1241	46.74.03
1242	46.74.04
1243	46.74.06
1244	47.52.06
1245	47.52.15
1246	15.20.15
1247	15.20.17
1248	15.20.18
1249	15.20.19
1250	22.19.05
1251	22.29.04
1252	46.16.01
1253	46.16.02
1254	46.42.02
1255	46.42.08
1256	47.64.06
1257	47.72.01
1258	47.72.06
1259	95.23.01
1260	96.09.01
1261	23.99.03
1262	25.99.08
1263	25.99.19
1264	27.20.01
1265	27.20.03
1266	28.11.10
1267	28.13.04
1268	28.15.02
1269	28.15.03
1270	28.29.18
1271	28.30.08
1272	28.30.10
1273	28.92.08
1274	28.92.09
1275	29.10.01
1276	29.10.02
1277	29.10.03
1278	29.10.04
1279	29.10.05
1280	29.10.07
1281	29.10.08
1282	29.20.01
1283	29.20.02
1284	29.20.03
1285	29.20.04
1286	29.20.05
1287	29.20.06
1288	29.31.04
1289	29.31.05
1290	29.31.06
1291	29.31.07
1292	29.32.20
1293	29.32.21
1381	47.52.13
1294	29.32.22
1295	30.12.01
1296	30.12.03
1297	30.12.04
1298	30.20.01
1299	30.20.02
1300	30.20.03
1301	30.20.04
1302	30.20.05
1303	30.91.01
1304	30.91.02
1305	30.91.03
1306	30.92.01
1307	30.92.02
1308	30.92.03
1309	30.92.04
1310	30.92.05
1311	30.99.01
1312	30.99.90
1313	45.20.01
1314	45.20.08
1315	45.31.10
1316	45.31.11
1317	45.31.12
1318	45.31.13
1319	45.31.14
1320	45.32.02
1321	45.32.03
1322	45.32.04
1323	45.32.05
1324	45.32.06
1325	45.32.90
1326	45.40.01
1327	45.40.05
1328	45.40.06
1329	45.40.07
1330	47.64.05
1331	47.78.27
1332	45.11.10
1333	45.11.11
1334	45.11.12
1335	45.11.13
1336	45.19.01
1337	45.19.02
1338	45.40.02
1339	45.40.03
1340	45.40.04
1341	28.11.08
1342	28.11.09
1343	30.11.01
1344	30.11.02
1345	30.11.03
1346	30.11.04
1347	30.11.05
1348	30.11.06
1349	30.11.07
1350	30.11.08
1351	30.30.01
1352	30.30.02
1353	30.30.03
1354	30.30.04
1355	30.30.05
1356	30.30.06
1357	30.30.07
1358	30.30.08
1359	30.40.01
1360	30.99.02
1361	33.15.01
1362	33.16.01
1363	33.17.01
1364	33.17.90
1365	45.20.02
1366	45.20.03
1367	45.20.04
1368	45.20.05
1369	45.20.06
1370	45.20.07
1371	46.14.03
1372	46.69.01
1373	46.69.03
1374	47.64.02
1375	95.29.05
1376	46.72.04
1377	46.72.05
1378	46.72.08
1379	46.72.09
1380	46.72.10
1382	24.41.19
1383	24.42.16
1384	24.42.17
1385	24.42.18
1386	24.42.20
1387	24.42.21
1388	24.43.01
1389	24.43.02
1390	24.43.04
1391	24.43.05
1392	24.43.06
1393	24.43.07
1394	24.43.08
1395	24.44.01
1396	24.44.03
1397	24.44.04
1398	24.45.01
1399	24.45.02
1400	24.45.06
1401	24.46.01
1402	32.12.03
1403	46.72.01
1404	46.72.02
1405	46.72.06
1406	46.72.07
1407	24.10.01
1408	24.10.02
1409	24.10.03
1410	24.10.05
1411	24.10.06
1412	24.10.07
1413	24.10.08
1414	24.10.09
1415	24.10.10
1416	24.10.12
1417	24.20.09
1418	24.20.10
1419	24.31.01
1420	24.32.01
1421	24.33.01
1422	24.34.01
1423	24.51.13
1424	24.52.20
1425	24.53.01
1426	24.54.01
1427	24.54.02
1428	25.50.01
1429	25.50.02
1430	25.62.01
1431	25.62.02
1432	25.73.03
1433	25.73.06
1434	25.11.06
1435	25.11.07
1436	25.11.08
1437	25.12.04
1438	25.12.05
1439	25.12.06
1440	25.29.01
1441	25.29.02
1442	25.71.01
1443	25.71.02
1444	25.71.03
1445	25.71.04
1446	25.71.05
1447	25.91.01
1448	25.92.01
1449	25.92.02
1450	25.92.03
1451	25.99.01
1452	25.99.02
1453	25.99.03
1454	25.99.04
1455	25.99.05
1456	25.99.06
1457	25.99.07
1458	25.99.09
1459	25.99.11
1460	25.99.12
1461	25.99.13
1462	25.99.15
1463	25.99.16
1464	25.99.17
1465	25.99.18
1466	25.99.20
1467	25.99.21
1468	28.21.07
1469	28.21.11
1470	32.12.08
1471	46.15.04
1472	46.49.07
1473	47.59.06
1474	47.59.09
1475	47.89.10
1476	25.21.10
1477	25.21.11
1478	25.21.12
1479	25.30.01
1480	25.30.02
1481	28.13.01
1482	28.13.03
1483	28.14.01
1484	28.14.02
1485	28.21.08
1486	28.21.09
1487	28.21.10
1488	28.21.90
1489	28.22.10
1490	28.22.11
1491	28.22.12
1492	28.22.13
1493	28.25.01
1494	28.25.02
1495	28.29.01
1496	28.29.02
1497	28.29.03
1498	28.29.04
1499	28.29.05
1500	28.29.06
1501	28.29.08
1502	28.29.09
1503	28.29.12
1504	28.29.17
1505	28.29.19
1506	28.29.20
1507	28.30.09
1508	28.30.11
1509	28.30.13
1510	28.30.14
1511	28.30.15
1512	28.92.01
1513	28.92.02
1514	28.92.03
1515	28.92.05
1516	28.92.06
1517	28.92.10
1518	28.92.11
1519	28.93.01
1520	28.93.02
1521	28.93.03
1522	28.93.04
1523	28.93.06
1524	28.93.07
1525	28.93.08
1526	28.93.09
1527	28.93.10
1528	28.94.01
1529	28.94.02
1530	28.94.03
1531	28.94.04
1532	28.94.05
1533	28.94.06
1534	28.94.07
1535	28.94.08
1536	28.94.09
1537	28.95.01
1538	28.96.01
1539	28.99.01
1540	28.99.02
1541	28.99.04
1542	28.99.05
1543	28.99.06
1544	28.99.07
1545	28.99.08
1546	28.99.09
1547	28.99.10
1548	28.99.11
1549	28.99.12
1550	28.99.90
1551	33.11.01
1552	33.11.02
1553	33.11.03
1554	33.11.04
1555	33.11.10
1556	33.11.90
1557	33.13.01
1558	33.13.02
1559	33.13.04
1560	33.14.03
1561	33.20.33
1562	33.20.34
1563	33.20.35
1564	33.20.36
1565	33.20.37
1566	33.20.38
1567	33.20.39
1568	33.20.40
1569	33.20.41
1570	33.20.42
1571	33.20.43
1572	33.20.44
1573	33.20.46
1574	33.20.48
1575	33.20.49
1576	33.20.52
1577	33.20.53
1578	33.20.54
1579	33.20.90
1580	43.29.01
1581	43.29.02
1582	46.14.02
1583	46.61.02
1584	46.63.01
1585	46.63.02
1586	46.64.01
1587	46.64.02
1588	28.12.05
1589	28.13.02
1590	28.41.01
1591	28.41.03
1592	28.41.06
1593	28.41.07
1594	28.49.02
1595	28.49.03
1596	28.49.04
1597	28.49.05
1598	28.49.90
1599	28.91.01
1600	28.91.02
1601	33.12.02
1602	33.12.03
1603	33.12.04
1604	33.12.05
1605	33.12.06
1606	33.12.07
1607	33.12.08
1608	33.12.09
1609	33.12.10
1610	33.12.11
1611	33.12.14
1612	33.12.15
1613	33.12.16
1614	33.12.17
1615	33.12.19
1616	33.12.21
1617	33.12.28
1618	33.12.29
1619	33.12.30
1620	33.19.90
1621	46.62.01
1622	46.62.02
1623	46.62.90
1624	46.69.07
1625	46.69.08
1626	46.69.11
1627	46.69.12
1628	46.69.14
1629	46.69.15
1630	13.92.07
1631	13.92.08
1632	22.29.02
1633	23.91.01
1634	25.40.01
1635	25.40.02
1636	25.40.03
1637	25.72.01
1638	25.73.02
1639	25.73.04
1640	25.93.01
1641	25.93.02
1642	25.93.03
1643	25.94.01
1644	25.94.02
1645	25.99.10
1646	25.99.14
1647	26.51.02
1648	26.51.03
1649	26.51.05
1650	26.51.06
1651	26.51.07
1652	26.51.09
1653	26.51.10
1654	26.51.11
1655	26.51.12
1656	26.51.13
1657	26.51.14
1658	26.51.15
1659	27.90.05
1660	28.15.01
1661	28.15.04
1662	28.24.01
1663	28.29.07
1664	28.29.10
1665	28.29.11
1666	28.30.12
1667	28.30.16
1668	28.30.17
1669	32.91.01
1670	32.91.02
1671	32.99.04
1672	32.99.08
1673	32.99.09
1674	32.99.10
1675	32.99.11
1676	32.99.13
1677	32.99.16
1678	33.12.12
1679	33.12.13
1680	33.12.27
1681	33.12.90
1682	35.22.02
1683	46.15.02
1684	46.61.03
1685	46.62.04
1686	46.69.04
1687	46.69.05
1688	46.69.06
1689	46.69.10
1690	46.69.13
1691	46.69.16
1692	46.69.17
1693	46.69.90
1694	46.74.01
1695	46.74.05
1696	46.74.07
1697	47.52.02
1698	47.52.16
1699	47.78.05
1700	47.78.23
1701	95.22.02
1702	95.29.04
1703	07.10.01
1704	07.21.01
1705	07.21.02
1706	07.21.03
1707	07.21.04
1708	07.21.05
1709	07.29.01
1710	07.29.02
1711	07.29.03
1712	07.29.04
1713	07.29.05
1714	07.29.06
1715	07.29.07
1716	08.11.01
1717	08.11.02
1718	08.11.03
1719	08.11.04
1720	08.11.05
1721	08.11.06
1722	08.11.07
1723	08.12.01
1724	08.12.02
1725	08.12.03
1726	08.91.01
1727	08.91.02
1728	08.91.03
1729	08.91.04
1730	08.91.05
1731	08.93.01
1732	08.99.01
1733	08.99.02
1734	08.99.03
1735	08.99.04
1736	08.99.05
1737	08.99.90
1738	09.10.01
1739	09.10.02
1740	09.90.01
1741	09.90.02
1742	23.70.01
1743	23.70.02
1744	46.73.10
1745	46.73.11
1746	47.52.19
1747	84.13.13
1748	06.20.01
1749	20.13.06
1750	35.11.19
1751	35.13.01
1752	35.14.02
1753	35.14.03
1754	35.21.01
1755	35.22.01
1756	35.23.01
1757	35.23.02
1758	35.30.21
1759	27.11.01
1760	27.11.03
1761	27.12.01
1762	27.12.02
1763	27.20.02
1764	27.20.04
1765	27.31.04
1766	27.32.03
1767	27.52.06
1768	27.90.02
1769	27.90.03
1770	27.90.04
1771	27.90.08
1772	27.90.09
1773	27.90.10
1774	27.90.90
1775	33.11.11
1776	33.14.01
1777	33.14.02
1778	33.20.51
1779	35.12.13
1780	35.13.02
1781	35.14.01
1782	43.21.01
1783	43.21.03
1784	46.43.05
1785	46.43.08
1786	46.69.09
1787	47.54.03
1788	23.19.03
1789	27.40.02
1790	27.40.03
1791	27.40.04
1792	27.40.05
1793	27.40.06
1794	27.40.07
1795	27.90.06
1796	46.47.03
1797	47.59.02
1798	26.40.08
1799	26.40.09
1800	26.40.10
1801	26.40.11
1802	26.40.12
1803	27.51.02
1804	27.51.03
1805	27.51.04
1806	27.51.05
1807	27.51.06
1808	27.51.07
1809	27.51.08
1810	27.51.90
1811	27.52.02
1812	27.52.05
1813	46.15.03
1814	46.43.01
1815	46.43.12
1935	20.30.11
1816	46.43.90
1817	46.49.16
1818	47.43.01
1819	47.54.01
1820	47.54.90
1821	47.79.04
1822	95.22.01
1823	95.22.03
1824	26.11.04
1825	26.11.05
1826	26.11.06
1827	26.11.90
1828	26.12.01
1829	26.30.02
1830	26.30.03
1831	26.30.05
1832	26.30.06
1833	26.30.08
1834	26.30.09
1835	26.30.10
1836	26.30.90
1837	26.40.90
1838	26.80.01
1839	26.80.02
1840	26.80.03
1841	26.80.90
1842	42.22.05
1843	46.43.04
1844	46.43.09
1845	46.52.01
1846	46.52.02
1847	46.52.04
1848	46.52.05
1849	47.42.01
1850	47.89.05
1851	61.10.15
1852	61.10.17
1853	61.20.02
1854	61.20.03
1855	61.30.01
1856	61.90.04
1857	61.90.07
1858	61.90.90
1859	80.20.01
1860	82.20.01
1861	82.99.06
1862	95.12.01
1863	95.21.01
1864	16.29.04
1865	20.16.01
1866	20.16.02
1867	20.16.03
1868	20.17.01
1869	22.11.17
1870	22.11.18
1871	22.11.19
1872	22.19.01
1873	22.19.02
1874	22.19.03
1875	22.19.04
1876	22.19.06
1877	22.19.07
1878	22.19.08
1879	22.19.09
1880	22.19.10
1881	22.19.12
1882	22.19.13
1883	22.21.03
1884	22.21.04
1885	22.22.43
1886	22.23.03
1887	22.23.04
1888	22.23.05
1889	22.23.06
1890	22.23.07
1891	22.23.08
1892	22.23.90
1893	22.29.01
1894	22.29.03
1895	22.29.05
1896	22.29.06
1897	22.29.07
1898	22.29.90
1899	25.73.05
1900	27.33.02
1901	31.09.08
1902	32.40.10
1903	32.91.90
1904	32.99.90
1905	46.49.17
1906	46.73.15
1907	46.73.17
1908	46.73.20
1909	46.76.04
1910	46.76.05
1911	47.52.09
1912	47.52.21
1913	47.59.07
1914	10.41.03
1915	19.20.16
1916	19.20.17
1917	19.20.19
1918	20.11.01
1919	20.12.01
1920	20.13.02
1921	20.13.03
1922	20.13.04
1923	20.13.07
1924	20.13.90
1925	20.14.01
1926	20.14.05
1927	20.15.01
1928	20.15.02
1929	20.16.04
1930	20.16.05
1931	20.20.11
1932	20.20.12
1933	20.20.13
1934	20.20.14
1936	20.30.12
1937	20.30.13
1938	20.41.01
1939	20.41.03
1940	20.41.04
1941	20.41.06
1942	20.51.21
1943	20.51.22
1944	20.51.23
1945	20.52.05
1946	20.53.02
1947	20.59.03
1948	20.59.04
1949	20.59.05
1950	20.59.07
1951	20.59.08
1952	20.59.09
1953	20.59.10
1954	20.59.11
1955	20.59.12
1956	20.59.13
1957	20.59.14
1958	20.59.15
1959	25.61.01
1960	25.61.02
1961	25.61.03
1962	32.99.14
1963	32.99.15
1964	32.99.17
1965	43.99.12
1966	46.12.01
1967	46.12.02
1968	46.12.03
1969	46.44.04
1970	46.73.02
1971	46.75.01
1972	46.75.02
1973	46.75.03
1974	46.75.04
1975	46.75.05
1976	47.52.03
1977	47.76.03
1978	02.40.01
1979	02.40.02
1980	16.10.01
1981	16.10.02
1982	16.10.03
1983	16.10.06
1984	16.21.01
1985	16.21.02
1986	16.22.01
1987	16.23.90
1988	16.24.01
1989	16.24.02
1990	16.24.03
1991	16.29.02
1992	16.29.05
1993	16.29.07
1994	46.13.02
1995	46.73.01
1996	46.73.12
1997	47.52.10
1998	31.01.01
1999	31.01.02
2000	31.01.03
2001	31.01.04
2002	31.02.01
2003	31.03.01
2004	31.03.02
2005	31.09.01
2006	31.09.02
2007	31.09.03
2008	31.09.04
2009	31.09.05
2010	31.09.06
2011	31.09.07
2012	43.32.01
2013	43.32.02
2014	43.32.03
2015	46.15.01
2016	46.47.01
2017	46.65.01
2018	47.59.03
2019	47.59.08
2020	47.59.10
2021	47.59.11
2022	47.89.01
2023	95.24.01
2024	10.39.03
2025	10.41.06
2026	10.71.01
2027	10.71.03
2028	10.72.01
2029	10.72.02
2030	10.72.03
2031	10.81.01
2032	10.81.03
2033	10.82.01
2034	10.82.02
2035	10.82.03
2036	10.82.04
2037	10.82.05
2038	10.82.06
2039	10.82.07
2040	10.83.01
2041	10.83.02
2042	10.83.03
2043	11.07.04
2044	46.36.01
2045	47.24.02
2046	47.24.03
2047	47.81.11
2048	56.10.09
2049	15.12.10
2050	15.12.11
2051	23.19.02
2052	26.51.04
2053	26.51.08
2054	26.51.90
2055	26.52.03
2056	26.52.04
2057	32.50.01
2058	32.50.08
2059	46.43.11
2060	46.48.02
2061	47.77.03
2062	47.78.03
2063	47.78.07
2064	95.25.01
2065	01.42.09
2066	01.44.01
2067	01.45.01
2068	01.46.01
2069	01.47.01
2070	01.49.05
2071	01.70.01
2072	01.70.02
2073	10.11.01
2074	10.12.01
2075	10.12.02
2076	10.12.03
2077	10.13.01
2078	10.13.02
2079	10.13.03
2080	10.13.04
2081	46.11.02
2082	46.23.01
2083	46.23.02
2084	46.32.01
2085	46.32.02
2086	46.32.03
2087	46.32.04
2088	47.22.01
2089	47.22.02
2090	47.78.28
2091	47.78.29
2092	47.81.03
2093	47.89.03
2094	47.89.14
2095	52.10.02
2096	52.10.03
2097	52.10.04
2098	52.10.05
2099	52.10.90
2100	52.21.06
2101	52.24.08
2102	52.24.09
2103	52.24.10
2104	52.24.11
2105	53.10.01
2106	53.20.08
2107	53.20.09
2108	53.20.10
2109	19.20.15
2110	46.71.03
2111	47.78.10
2112	49.50.04
2113	13.20.14
2114	13.20.16
2115	13.20.17
2116	13.20.19
2117	13.20.20
2118	13.20.21
2119	13.20.22
2120	13.20.23
2121	13.20.24
2122	13.92.05
2123	13.96.01
2124	13.96.06
2125	14.19.02
2126	01.11.07
2127	01.11.12
2128	01.11.14
2129	01.12.14
2130	01.25.09
2131	01.63.02
2132	10.39.02
2133	10.39.06
2134	46.21.02
2135	46.21.03
2136	46.21.08
2137	46.31.01
2138	46.31.08
2139	46.31.09
2140	46.31.10
2141	46.31.11
2142	46.31.12
2143	47.21.04
2144	47.21.05
2145	47.29.06
2146	47.81.90
2147	20.59.01
2148	26.70.16
2149	26.70.19
2150	27.40.01
2151	33.13.03
2152	46.43.10
2153	46.49.23
2154	46.49.24
2155	47.78.22
2156	47.89.07
2157	74.20.22
2158	74.20.25
2159	74.20.26
2160	74.20.27
2161	74.20.28
2162	74.20.29
2163	74.20.90
2164	96.09.16
2165	16.29.01
2166	16.29.03
2167	23.13.01
2168	23.13.02
2169	23.41.01
2170	46.44.01
2171	47.59.01
2172	47.59.04
2173	02.10.01
2174	02.20.01
2175	05.10.01
2176	05.20.01
2177	08.92.01
2178	16.29.90
2179	19.10.10
2180	19.10.11
2181	19.20.12
2182	20.14.04
2183	35.21.02
2184	46.71.02
2185	47.78.02
2186	47.99.12
2188	10.20
2189	10.30
2190	10.40
2191	10.50
2187	10.10
2192	10.60
2193	10.70
2194	10.80
2195	10.90
2196	11.00
2197	11.20
2198	11.30
2199	11.40
2200	11.50
2201	11.60
2202	11.90
2203	12.00
2204	12.10
2205	12.20
2206	12.30
2207	12.40
2208	12.50
2209	12.60
2210	12.70
2211	12.80
2212	12.90
2213	13.00
2214	13.10
2215	13.20
2216	13.30
2217	13.90
2218	14.10
2219	14.10
2220	14.20
2221	14.20
2222	14.30
2223	14.30
2224	14.40
2225	14.50
2226	14.60
2227	14.70
2228	14.90
2229	15.00
2230	15.10
2231	15.20
2232	16.10
2233	16.10
2234	16.20
2235	16.20
2236	16.30
2237	16.40
2238	17.00
2239	17.10
2240	17.20
2241	18.10
2242	18.20
2243	19.10
2244	19.20
2245	20.10
2246	20.20
2247	20.30
2248	20.40
2249	20.50
2250	20.60
2251	21.00
2252	21.10
2253	21.20
2254	22.00
2255	22.10
2256	22.20
2257	23.00
2258	23.10
2259	23.20
2260	23.30
2261	23.40
2262	23.50
2263	23.60
2264	23.70
2265	23.90
2266	24.00
2267	24.10
2268	24.20
2269	24.30
2270	24.40
2271	24.50
2272	25.10
2273	25.20
2274	25.30
2275	25.40
2276	25.50
2277	25.60
2278	25.70
2279	25.90
2280	26.10
2281	26.20
2282	26.30
2283	26.40
2284	26.50
2285	26.60
2286	26.70
2287	26.80
2288	27.10
2289	27.20
2290	27.30
2291	27.40
2292	27.50
2293	27.90
2294	28.10
2295	28.20
2296	28.30
2297	28.40
2298	28.90
2299	29.10
2300	29.20
2301	29.30
2302	30.10
2303	30.20
2304	30.30
2305	30.40
2306	30.90
2307	31.00
2308	31.10
2309	31.20
2310	32.10
2311	32.10
2312	32.20
2313	32.20
2314	32.30
2315	32.40
2316	32.50
2317	32.90
2318	33.10
2319	33.20
2320	35.10
2321	35.20
2322	35.30
2323	36.00
2324	37.00
2325	38.10
2326	38.20
2327	38.30
2328	39.00
2329	41.10
2330	41.20
2331	42.10
2332	42.20
2333	42.90
2334	43.10
2335	43.20
2336	43.30
2337	43.90
2338	45.10
2339	45.20
2340	45.30
2341	45.40
2342	46.10
2343	46.20
2344	46.30
2345	46.40
2346	46.50
2347	46.60
2348	46.70
2349	46.90
2350	47.10
2351	47.20
2352	47.30
2353	47.40
2354	47.50
2355	47.60
2356	47.70
2357	47.80
2358	47.90
2359	49.10
2360	49.20
2361	49.30
2362	49.40
2363	49.50
2364	50.10
2365	50.20
2366	50.30
2367	50.40
2368	51.00
2369	51.10
2370	51.20
2371	52.00
2372	52.10
2373	52.20
2374	53.10
2375	53.20
2376	55.10
2377	55.20
2378	55.30
2379	55.90
2380	56.10
2381	56.20
2382	56.30
2383	58.10
2384	58.20
2385	59.10
2386	59.20
2387	60.10
2388	60.20
2389	61.00
2390	61.10
2391	61.20
2392	61.30
2393	61.90
2394	62.00
2395	62.00
2396	63.10
2397	63.90
2398	64.10
2399	64.20
2400	64.30
2401	64.90
2402	65.10
2403	65.20
2404	65.30
2405	66.10
2406	66.20
2407	66.30
2408	68.10
2409	68.20
2410	68.30
2411	69.10
2412	69.20
2413	70.10
2414	70.20
2415	71.00
2416	71.10
2417	71.20
2418	72.10
2419	72.10
2420	72.20
2421	72.90
2422	73.10
2423	73.20
2424	74.10
2425	74.20
2426	74.30
2427	74.90
2428	75.00
2429	77.10
2430	77.20
2431	77.30
2432	77.40
2433	78.10
2434	78.20
2435	78.30
2436	79.10
2437	79.90
2438	80.10
2439	80.20
2440	80.30
2441	81.10
2442	81.10
2443	81.20
2444	81.20
2445	81.30
2446	82.10
2447	82.20
2448	82.30
2449	82.90
2450	84.10
2451	84.20
2452	84.30
2453	85.10
2454	85.20
2455	85.30
2456	85.40
2457	85.50
2458	85.60
2459	86.10
2460	86.20
2461	86.90
2462	87.10
2463	87.20
2464	87.30
2465	87.90
2466	88.10
2467	88.90
2468	89.10
2469	89.20
2470	89.30
2471	89.90
2472	90.00
2473	91.00
2475	92.00
2476	93.10
2477	93.20
2478	94.10
2479	94.20
2480	94.90
2481	95.10
2482	95.20
2483	96.00
2484	97.00
2485	98.10
2486	98.20
2487	99.00
2488	12.00
2489	13.20
2490	13.30
2491	13.91
2492	13.92
2493	13.93
2494	13.94
2495	13.95
2496	13.96
2497	13.99
2498	14.13
2499	14.14
2500	14.19
2501	14.20
2502	14.31
2503	14.39
2504	15.20
2505	16.21
2506	16.22
2507	16.23
2508	16.24
2509	16.29
2510	17.21
2511	17.22
2512	17.23
2513	17.24
2514	17.29
2515	18.13
2516	18.14
2517	18.20
2518	19.20
2519	20.13
2520	20.14
2521	20.15
2522	20.16
2523	20.17
2524	20.20
2525	20.30
2526	20.41
2527	20.42
2528	20.51
2529	20.52
2530	20.53
2531	20.59
2532	20.60
2533	21.20
2534	22.19
2535	22.21
2536	22.22
2537	22.23
2538	22.29
2539	23.13
2540	23.14
2541	23.19
2542	23.20
2543	23.31
2544	23.32
2545	23.41
2546	23.42
2547	23.43
2548	23.44
2549	23.49
2550	23.51
2551	23.52
2552	23.61
2553	23.62
2554	23.63
2555	23.64
2556	23.65
2557	23.69
2558	23.70
2559	23.91
2560	23.99
2561	24.20
2562	24.31
2563	24.32
2564	24.33
2565	24.34
2566	24.41
2567	24.42
2568	24.43
2569	24.44
2570	24.45
2571	24.46
2572	24.51
2573	24.52
2574	24.53
2575	24.54
2576	25.21
2577	25.29
2578	25.30
2579	25.40
2580	25.50
2581	25.61
2582	25.62
2583	25.71
2584	25.72
2585	25.73
2586	25.91
2587	25.92
2588	25.93
2589	25.94
2590	25.99
2591	26.20
2592	26.30
2593	26.40
2594	26.51
2595	26.52
2596	26.60
2597	26.70
2598	26.80
2599	27.20
2600	27.31
2601	27.32
2602	27.33
2603	27.40
2604	27.51
2605	27.52
2606	27.90
2607	28.13
2608	28.14
2609	28.15
2610	28.21
2611	28.22
2612	28.23
2613	28.24
2614	28.25
2615	28.29
2616	28.30
2617	28.41
2618	28.49
2619	28.91
2620	28.92
2621	28.93
2622	28.94
2623	28.95
2624	28.96
2625	28.99
2626	29.20
2627	29.31
2628	29.32
2629	30.20
2630	30.30
2631	30.40
2632	30.91
2633	30.92
2634	30.99
2635	31.02
2636	31.09
2637	32.11
2638	32.12
2639	32.13
2640	32.20
2641	32.30
2642	32.40
2643	32.50
2644	32.91
2645	32.99
2646	33.11
2647	33.12
2648	33.13
2649	33.14
2650	33.15
2651	33.16
2652	33.17
2653	33.19
2654	33.20
2655	35.11
2656	35.12
2657	35.13
2658	35.14
2659	35.21
2660	35.22
2661	35.23
2662	35.30
2663	36.00
2664	37.00
2665	38.11
2666	38.12
2667	38.21
2668	38.22
2669	38.31
2670	38.32
2671	39.00
2672	41.10
2673	41.20
2674	42.11
2675	42.12
2676	42.13
2677	42.21
2678	42.22
2679	42.91
2680	42.99
2681	43.11
2682	43.12
2683	43.13
2684	43.21
2685	43.22
2686	43.29
2687	43.31
2688	43.32
2689	43.33
2690	43.34
2691	43.39
2692	43.91
2693	43.99
2694	45.11
2695	45.19
2696	45.20
2697	45.31
2698	45.32
2699	45.40
2700	46.11
2701	46.12
2702	46.13
2703	46.14
2704	46.15
2705	46.16
2706	46.17
2707	46.18
2708	46.19
2709	46.21
2710	46.22
2711	46.23
2712	46.24
2713	46.31
2714	46.32
2715	46.33
2716	46.34
2717	46.35
2718	46.36
2719	46.37
2720	46.38
2721	46.39
2722	46.41
2723	46.42
2724	46.43
2725	46.44
2726	46.45
2727	46.46
2728	46.47
2729	46.48
2730	46.49
2731	46.51
2732	46.52
2733	46.61
2734	46.62
2735	46.63
2736	46.64
2737	46.65
2738	46.66
2739	46.69
2740	46.71
2741	46.72
2742	46.73
2743	46.74
2744	46.75
2745	46.76
2746	46.77
2747	46.90
2748	47.11
2749	47.19
2750	47.21
2751	47.22
2752	47.23
2753	47.24
2754	47.25
2755	47.26
2756	47.29
2757	47.30
2758	47.41
2759	47.42
2760	47.43
2761	47.51
2762	47.52
2763	47.53
2764	47.54
2765	47.59
2766	47.61
2767	47.62
2768	47.63
2769	47.64
2770	47.65
2771	47.71
2772	47.72
2773	47.73
2774	47.74
2775	47.75
2776	47.76
2777	47.77
2778	47.78
2779	47.79
2780	47.81
2781	47.82
2782	47.89
2783	47.91
2784	47.99
2785	49.10
2786	49.20
2787	49.31
2788	49.32
2789	49.39
2790	49.41
2791	49.42
2792	49.50
2793	50.10
2794	50.20
2795	50.30
2796	50.40
2797	51.10
2798	51.21
2799	51.22
2800	52.10
2801	52.21
2802	52.22
2803	52.23
2804	52.24
2805	52.29
2806	53.10
2807	53.20
2808	55.10
2809	55.20
2810	55.30
2811	55.90
2812	56.10
2813	56.21
2814	56.29
2815	56.30
2816	58.11
2817	58.12
2818	58.13
2819	58.14
2820	58.19
2821	58.21
2822	58.29
2823	59.11
2824	59.12
2825	59.13
2826	59.14
2827	59.20
2828	60.10
2829	60.20
2830	61.10
2831	61.20
2832	61.30
2833	61.90
2834	62.01
2835	62.02
2836	62.03
2837	62.09
2838	63.11
2839	63.12
2840	63.91
2841	63.99
2842	64.11
2843	64.19
2844	64.20
2845	64.30
2846	64.91
2847	64.92
2848	64.99
2849	65.11
2850	65.12
2851	65.20
2852	65.30
2853	66.11
2854	66.12
2855	66.19
2856	66.21
2857	66.22
2858	66.29
2859	66.30
2860	68.10
2861	68.20
2862	68.31
2863	68.32
2864	69.10
2865	69.20
2866	70.10
2867	70.21
2868	70.22
2869	71.11
2870	71.12
2871	71.20
2872	72.11
2873	72.19
2874	72.20
2875	73.11
2876	73.12
2877	73.20
2878	74.10
2879	74.20
2880	74.30
2881	74.90
2882	75.00
2883	77.11
2884	77.12
2885	77.21
2886	77.22
2887	77.29
2888	77.31
2889	77.32
2890	77.33
2891	77.34
2892	77.35
2893	77.39
2894	77.40
2895	78.10
2896	78.20
2897	78.30
2898	79.11
2899	79.12
2900	79.90
2901	80.10
2902	80.20
2903	80.30
2904	81.10
2905	81.21
2906	81.22
2907	81.29
2908	81.30
2909	82.11
2910	82.19
2911	82.20
2912	82.30
2913	82.91
2914	82.92
2915	82.99
2916	84.11
2917	84.12
2918	84.13
2919	84.21
2920	84.22
2921	84.23
2922	84.24
2923	84.25
2924	84.30
2925	85.10
2926	85.20
2927	85.31
2928	85.32
2929	85.41
2930	85.42
2931	85.51
2932	85.52
2933	85.53
2934	85.59
2935	85.60
2936	86.10
2937	86.21
2938	86.22
2939	86.23
2940	86.90
2941	87.10
2942	87.20
2943	87.30
2944	87.90
2945	88.10
2946	88.91
2947	88.99
2948	90.01
2949	90.02
2950	90.03
2951	90.04
2952	91.01
2953	91.02
2954	91.03
2955	91.04
2956	92.00
2957	93.11
2958	93.12
2959	93.13
2960	93.19
2961	93.21
2962	93.29
2963	94.11
2964	94.12
2965	94.20
2966	94.91
2967	94.92
2968	94.99
2969	95.11
2970	95.12
2971	95.21
2972	95.22
2973	95.23
2974	95.24
2975	95.25
2976	95.29
2977	96.01
2978	96.02
2979	96.03
2980	96.04
2981	96.09
2982	97.00
2983	98.10
2984	98.20
2985	99.00
\.


--
-- Data for Name: t_nace_code_rev2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_nace_code_rev2 (id, code, name, active) FROM stdin;
1	A.01.11	Growing of cereals (except rice), leguminous crops and oil seeds	0
2	A.01.12	Growing of rice	0
3	A.01.13	Growing of vegetables and melons, roots and tubers	0
4	A.01.14	Growing of sugar cane	0
5	A.01.15	Growing of tobacco	0
6	A.01.16	Growing of fibre crops	0
7	A.01.19	Growing of other non-perennial crops	0
8	A.01.21	Growing of grapes	0
9	A.01.22	Growing of tropical and subtropical fruits	0
10	A.01.23	Growing of citrus fruits	0
11	A.01.24	Growing of pome fruits and stone fruits	0
12	A.01.25	Growing of other tree and bush fruits and nuts	0
13	A.01.26	Growing of oleaginous fruits	0
14	A.01.27	Growing of beverage crops	0
15	A.01.28	Growing of spices, aromatic, drug and pharmaceutical crops	0
16	A.01.29	Growing of other perennial crops	0
17	A.01.30	Plant propagation	0
18	A.01.41	Raising of dairy cattle	0
19	A.01.42	Raising of other cattle and buffaloes	0
20	A.01.43	Raising of horses and other equines	0
21	A.01.44	Raising of camels and camelids	0
22	A.01.45	Raising of sheep and goats	0
23	A.01.46	Raising of swine/pigs	0
24	A.01.47	Raising of poultry	0
25	A.01.49	Raising of other animals	0
26	A.01.50	Mixed farming	0
27	A.01.61	Support activities for crop production	0
28	A.01.62	Support activities for animal production	0
29	A.01.63	Post-harvest crop activities	0
30	A.01.64	Seed processing for propagation	0
31	A.01.70	Hunting, trapping and related service activities	0
32	A.02.10	Silviculture and other forestry activities	0
33	A.02.20	Logging	0
34	A.02.30	Gathering of wild growing non-wood products	0
35	A.02.40	Support services to forestry	0
36	A.03.11	Marine fishing	0
37	A.03.12	Freshwater fishing	0
38	A.03.21	Marine aquaculture	0
39	A.03.22	Freshwater aquaculture	0
40	B.05.10	Mining of hard coal	0
41	B.05.20	Mining of lignite	0
42	B.06.10	Extraction of crude petroleum	0
43	B.06.20	Extraction of natural gas	0
44	B.07.10	Mining of iron ores	0
45	B.07.21	Mining of uranium and thorium ores	0
46	B.07.29	Mining of other non-ferrous metal ores	0
47	B.08.11	Quarrying of ornamental and building stone, limestone, gypsum, chalk and slate	0
48	B.08.12	Operation of gravel and sand pits; mining of clays and kaolin	0
49	B.08.91	Mining of chemical and fertiliser minerals	0
50	B.08.92	Extraction of peat	0
51	B.08.93	Extraction of salt	0
52	B.08.99	Other mining and quarrying n.e.c.	0
53	B.09.10	Support activities for petroleum and natural gas extraction	0
54	B.09.90	Support activities for other mining and quarrying	0
55	C.10.11	Processing and preserving of meat	0
56	C.10.12	Processing and preserving of poultry meat	0
57	C.10.13	Production of meat and poultry meat products	0
58	C.10.20	Processing and preserving of fish, crustaceans and molluscs	0
59	C.10.31	Processing and preserving of potatoes	0
60	C.10.32	Manufacture of fruit and vegetable juice	0
61	C.10.39	Other processing and preserving of fruit and vegetables	0
62	C.10.41	Manufacture of oils and fats	0
63	C.10.42	Manufacture of margarine and similar edible fats	0
64	C.10.51	Operation of dairies and cheese making	0
65	C.10.52	Manufacture of ice cream	0
66	C.10.61	Manufacture of grain mill products	0
67	C.10.62	Manufacture of starches and starch products	0
68	C.10.71	Manufacture of bread; manufacture of fresh pastry goods and cakes	0
69	C.10.72	Manufacture of rusks and biscuits; manufacture of preserved pastry goods and cakes	0
70	C.10.73	Manufacture of macaroni, noodles, couscous and similar farinaceous products	0
71	C.10.81	Manufacture of sugar	0
72	C.10.82	Manufacture of cocoa, chocolate and sugar confectionery	0
73	C.10.83	Processing of tea and coffee	0
74	C.10.84	Manufacture of condiments and seasonings	0
75	C.10.85	Manufacture of prepared meals and dishes	0
76	C.10.86	Manufacture of homogenised food preparations and dietetic food	0
77	C.10.89	Manufacture of other food products n.e.c.	0
78	C.10.91	Manufacture of prepared feeds for farm animals	0
79	C.10.92	Manufacture of prepared pet foods	0
80	C.11.01	Distilling, rectifying and blending of spirits	0
81	C.11.02	Manufacture of wine from grape	0
82	C.11.03	Manufacture of cider and other fruit wines	0
83	C.11.04	Manufacture of other non-distilled fermented beverages	0
84	C.11.05	Manufacture of beer	0
85	C.11.06	Manufacture of malt	0
86	C.11.07	Manufacture of soft drinks; production of mineral waters and other bottled waters	0
87	C.12.00	Manufacture of tobacco products	0
88	C.13.10	Preparation and spinning of textile fibres	0
89	C.13.20	Weaving of textiles	0
90	C.13.30	Finishing of textiles	0
91	C.13.91	Manufacture of knitted and crocheted fabrics	0
92	C.13.92	Manufacture of made-up textile articles, except apparel	0
93	C.13.93	Manufacture of carpets and rugs	0
94	C.13.94	Manufacture of cordage, rope, twine and netting	0
95	C.13.95	Manufacture of non-wovens and articles made from non-wovens, except apparel	0
96	C.13.96	Manufacture of other technical and industrial textiles	0
97	C.13.99	Manufacture of other textiles n.e.c.	0
98	C.14.11	Manufacture of leather clothes	0
99	C.14.12	Manufacture of workwear	0
100	C.14.13	Manufacture of other outerwear	0
101	C.14.14	Manufacture of underwear	0
102	C.14.19	Manufacture of other wearing apparel and accessories	0
103	C.14.20	Manufacture of articles of fur	0
104	C.14.31	Manufacture of knitted and crocheted hosiery	0
105	C.14.39	Manufacture of other knitted and crocheted apparel	0
106	C.15.11	Tanning and dressing of leather; dressing and dyeing of fur	0
107	C.15.12	Manufacture of luggage, handbags and the like, saddlery and harness	0
108	C.15.20	Manufacture of footwear	0
109	C.16.10	Sawmilling and planing of wood	0
110	C.16.21	Manufacture of veneer sheets and wood-based panels	0
111	C.16.22	Manufacture of assembled parquet floors	0
112	C.16.23	Manufacture of other builders carpentry and joinery	0
113	C.16.24	Manufacture of wooden containers	0
114	C.16.29	Manufacture of other products of wood; manufacture of articles of cork, straw and plaiting materials	0
115	C.17.11	Manufacture of pulp	0
116	C.17.12	Manufacture of paper and paperboard	0
117	C.17.21	Manufacture of corrugated paper and paperboard and of containers of paper and paperboard	0
118	C.17.22	Manufacture of household and sanitary goods and of toilet requisites	0
119	C.17.23	Manufacture of paper stationery	0
120	C.17.24	Manufacture of wallpaper	0
121	C.17.29	Manufacture of other articles of paper and paperboard	0
122	C.18.11	Printing of newspapers	0
123	C.18.12	Other printing	0
124	C.18.13	Pre-press and pre-media services	0
125	C.18.14	Binding and related services	0
126	C.18.20	Reproduction of recorded media	0
127	C.19.10	Manufacture of coke oven products	0
128	C.19.20	Manufacture of refined petroleum products	0
129	C.20.11	Manufacture of industrial gases	0
130	C.20.12	Manufacture of dyes and pigments	0
131	C.20.13	Manufacture of other inorganic basic chemicals	0
132	C.20.14	Manufacture of other organic basic chemicals	0
133	C.20.15	Manufacture of fertilisers and nitrogen compounds	0
134	C.20.16	Manufacture of plastics in primary forms	0
135	C.20.17	Manufacture of synthetic rubber in primary forms	0
136	C.20.20	Manufacture of pesticides and other agrochemical products	0
137	C.20.30	Manufacture of paints, varnishes and similar coatings, printing ink and mastics	0
138	C.20.41	Manufacture of soap and detergents, cleaning and polishing preparations	0
139	C.20.42	Manufacture of perfumes and toilet preparations	0
140	C.20.51	Manufacture of explosives	0
141	C.20.52	Manufacture of glues	0
142	C.20.53	Manufacture of essential oils	0
143	C.20.59	Manufacture of other chemical products n.e.c.	0
144	C.20.60	Manufacture of man-made fibres	0
145	C.21.10	Manufacture of basic pharmaceutical products	0
146	C.21.20	Manufacture of pharmaceutical preparations	0
147	C.22.11	Manufacture of rubber tyres and tubes; retreading and rebuilding of rubber tyres	0
148	C.22.19	Manufacture of other rubber products	0
149	C.22.21	Manufacture of plastic plates, sheets, tubes and profiles	0
150	C.22.22	Manufacture of plastic packing goods	0
151	C.22.23	Manufacture of buildersÔÇÖ ware of plastic	0
152	C.22.29	Manufacture of other plastic products	0
153	C.23.11	Manufacture of flat glass	0
154	C.23.12	Shaping and processing of flat glass	0
155	C.23.13	Manufacture of hollow glass	0
156	C.23.14	Manufacture of glass fibres	0
157	C.23.19	Manufacture and processing of other glass, including technical glassware	0
158	C.23.20	Manufacture of refractory products	0
159	C.23.31	Manufacture of ceramic tiles and flags	0
160	C.23.32	Manufacture of bricks, tiles and construction products, in baked clay	0
161	C.23.41	Manufacture of ceramic household and ornamental articles	0
162	C.23.42	Manufacture of ceramic sanitary fixtures	0
163	C.23.43	Manufacture of ceramic insulators and insulating fittings	0
164	C.23.44	Manufacture of other technical ceramic products	0
165	C.23.49	Manufacture of other ceramic products	0
166	C.23.51	Manufacture of cement	0
167	C.23.52	Manufacture of lime and plaster	0
168	C.23.61	Manufacture of concrete products for construction purposes	0
169	C.23.62	Manufacture of plaster products for construction purposes	0
170	C.23.63	Manufacture of ready-mixed concrete	0
171	C.23.64	Manufacture of mortars	0
172	C.23.65	Manufacture of fibre cement	0
173	C.23.69	Manufacture of other articles of concrete, plaster and cement	0
174	C.23.70	Cutting, shaping and finishing of stone	0
175	C.23.91	Production of abrasive products	0
176	C.23.99	Manufacture of other non-metallic mineral products n.e.c.	0
177	C.24.10	Manufacture of basic iron and steel and of ferro-alloys 	0
178	C.24.20	Manufacture of tubes, pipes, hollow profiles and related fittings, of steel	0
179	C.24.31	Cold drawing of bars	0
180	C.24.32	Cold rolling of narrow strip	0
181	C.24.33	Cold forming or folding	0
182	C.24.34	Cold drawing of wire	0
183	C.24.41	Precious metals production	0
184	C.24.42	Aluminium production	0
185	C.24.43	Lead, zinc and tin production	0
186	C.24.44	Copper production	0
187	C.24.45	Other non-ferrous metal production	0
188	C.24.46	Processing of nuclear fuel 	0
189	C.24.51	Casting of iron	0
190	C.24.52	Casting of steel	0
191	C.24.53	Casting of light metals	0
192	C.24.54	Casting of other non-ferrous metals	0
193	C.25.11	Manufacture of metal structures and parts of structures	0
194	C.25.12	Manufacture of doors and windows of metal	0
195	C.25.21	Manufacture of central heating radiators and boilers	0
196	C.25.29	Manufacture of other tanks, reservoirs and containers of metal	0
197	C.25.30	Manufacture of steam generators, except central heating hot water boilers	0
198	C.25.40	Manufacture of weapons and ammunition	0
199	C.25.50	Forging, pressing, stamping and roll-forming of metal; powder metallurgy	0
200	C.25.61	Treatment and coating of metals	0
201	C.25.62	Machining	0
202	C.25.71	Manufacture of cutlery	0
203	C.25.72	Manufacture of locks and hinges	0
204	C.25.73	Manufacture of tools	0
205	C.25.91	Manufacture of steel drums and similar containers	0
206	C.25.92	Manufacture of light metal packaging 	0
207	C.25.93	Manufacture of wire products, chain and springs	0
208	C.25.94	Manufacture of fasteners and screw machine products	0
209	C.25.99	Manufacture of other fabricated metal products n.e.c.	0
210	C.26.11	Manufacture of electronic components	0
211	C.26.12	Manufacture of loaded electronic boards	0
212	C.26.20	Manufacture of computers and peripheral equipment	0
213	C.26.30	Manufacture of communication equipment	0
214	C.26.40	Manufacture of consumer electronics	0
215	C.26.51	Manufacture of instruments and appliances for measuring, testing and navigation	0
216	C.26.52	Manufacture of watches and clocks	0
217	C.26.60	Manufacture of irradiation, electromedical and electrotherapeutic equipment	0
218	C.26.70	Manufacture of optical instruments and photographic equipment	0
219	C.26.80	Manufacture of magnetic and optical media	0
220	C.27.11	Manufacture of electric motors, generators and transformers	0
221	C.27.12	Manufacture of electricity distribution and control apparatus	0
222	C.27.20	Manufacture of batteries and accumulators	0
223	C.27.31	Manufacture of fibre optic cables	0
224	C.27.32	Manufacture of other electronic and electric wires and cables	0
225	C.27.33	Manufacture of wiring devices	0
226	C.27.40	Manufacture of electric lighting equipment	0
227	C.27.51	Manufacture of electric domestic appliances	0
228	C.27.52	Manufacture of non-electric domestic appliances	0
229	C.27.90	Manufacture of other electrical equipment	0
230	C.28.11	Manufacture of engines and turbines, except aircraft, vehicle and cycle engines	0
231	C.28.12	Manufacture of fluid power equipment	0
232	C.28.13	Manufacture of other pumps and compressors	0
233	C.28.14	Manufacture of other taps and valves	0
234	C.28.15	Manufacture of bearings, gears, gearing and driving elements	0
235	C.28.21	Manufacture of ovens, furnaces and furnace burners	0
236	C.28.22	Manufacture of lifting and handling equipment	0
237	C.28.23	Manufacture of office machinery and equipment (except computers and peripheral equipment)	0
238	C.28.24	Manufacture of power-driven hand tools	0
239	C.28.25	Manufacture of non-domestic cooling and ventilation equipment	0
240	C.28.29	Manufacture of other general-purpose machinery n.e.c.	0
241	C.28.30	Manufacture of agricultural and forestry machinery	0
242	C.28.41	Manufacture of metal forming machinery	0
243	C.28.49	Manufacture of other machine tools	0
244	C.28.91	Manufacture of machinery for metallurgy	0
245	C.28.92	Manufacture of machinery for mining, quarrying and construction	0
246	C.28.93	Manufacture of machinery for food, beverage and tobacco processing	0
247	C.28.94	Manufacture of machinery for textile, apparel and leather production	0
248	C.28.95	Manufacture of machinery for paper and paperboard production	0
249	C.28.96	Manufacture of plastics and rubber machinery	0
250	C.28.99	Manufacture of other special-purpose machinery n.e.c.	0
251	C.29.10	Manufacture of motor vehicles	0
252	C.29.20	Manufacture of bodies (coachwork) for motor vehicles; manufacture of trailers and semi-trailers	0
253	C.29.31	Manufacture of electrical and electronic equipment for motor vehicles	0
254	C.29.32	Manufacture of other parts and accessories for motor vehicles	0
255	C.30.11	Building of ships and floating structures	0
256	C.30.12	Building of pleasure and sporting boats	0
257	C.30.20	Manufacture of railway locomotives and rolling stock	0
258	C.30.30	Manufacture of air and spacecraft and related machinery	0
259	C.30.40	Manufacture of military fighting vehicles	0
260	C.30.91	Manufacture of motorcycles	0
261	C.30.92	Manufacture of bicycles and invalid carriages	0
262	C.30.99	Manufacture of other transport equipment n.e.c.	0
263	C.31.01	Manufacture of office and shop furniture	0
264	C.31.02	Manufacture of kitchen furniture	0
265	C.31.03	Manufacture of mattresses	0
266	C.31.09	Manufacture of other furniture	0
267	C.32.11	Striking of coins	0
268	C.32.12	Manufacture of jewellery and related articles	0
269	C.32.13	Manufacture of imitation jewellery and related articles	0
270	C.32.20	Manufacture of musical instruments	0
271	C.32.30	Manufacture of sports goods	0
272	C.32.40	Manufacture of games and toys	0
273	C.32.50	Manufacture of medical and dental instruments and supplies	0
274	C.32.91	Manufacture of brooms and brushes	0
275	C.32.99	Other manufacturing n.e.c. 	0
276	C.33.11	Repair of fabricated metal products	0
277	C.33.12	Repair of machinery	0
278	C.33.13	Repair of electronic and optical equipment	0
279	C.33.14	Repair of electrical equipment	0
280	C.33.15	Repair and maintenance of ships and boats	0
281	C.33.16	Repair and maintenance of aircraft and spacecraft	0
282	C.33.17	Repair and maintenance of other transport equipment	0
283	C.33.19	Repair of other equipment	0
284	C.33.20	Installation of industrial machinery and equipment	0
285	D.35.11	Production of electricity	0
286	D.35.12	Transmission of electricity	0
287	D.35.13	Distribution of electricity	0
288	D.35.14	Trade of electricity	0
289	D.35.21	Manufacture of gas	0
290	D.35.22	Distribution of gaseous fuels through mains	0
291	D.35.23	Trade of gas through mains	0
292	D.35.30	Steam and air conditioning supply	0
293	E.36.00	Water collection, treatment and supply	0
294	E.37.00	Sewerage	0
295	E.38.11	Collection of non-hazardous waste	0
296	E.38.12	Collection of hazardous waste	0
297	E.38.21	Treatment and disposal of non-hazardous waste	0
298	E.38.22	Treatment and disposal of hazardous waste	0
299	E.38.31	Dismantling of wrecks	0
300	E.38.32	Recovery of sorted materials	0
301	E.39.00	Remediation activities and other waste management services	0
302	F.41.10	Development of building projects	0
303	F.41.20	Construction of residential and non-residential buildings	0
304	F.42.11	Construction of roads and motorways	0
305	F.42.12	Construction of railways and underground railways	0
306	F.42.13	Construction of bridges and tunnels	0
307	F.42.21	Construction of utility projects for fluids	0
308	F.42.22	Construction of utility projects for electricity and telecommunications	0
309	F.42.91	Construction of water projects	0
310	F.42.99	Construction of other civil engineering projects n.e.c.	0
311	F.43.11	Demolition	0
312	F.43.13	Test drilling and boring	0
313	F.43.21	Electrical installation	0
314	F.43.22	Plumbing, heat and air-conditioning installation	0
315	F.43.29	Other construction installation	0
316	F.43.31	Plastering	0
317	F.43.32	Joinery installation	0
318	F.43.33	Floor and wall covering	0
319	F.43.34	Painting and glazing	0
320	F.43.39	Other building completion and finishing	0
321	F.43.91	Roofing activities	0
322	F.43.99	Other specialised construction activities n.e.c.	0
323	F.44.12	Site preparation	0
324	G.45.11	Sale of cars and light motor vehicles	0
325	G.45.19	Sale of other motor vehicles	0
326	G.45.20	Maintenance and repair of motor vehicles	0
327	G.45.31	Wholesale trade of motor vehicle parts and accessories	0
328	G.45.32	Retail trade of motor vehicle parts and accessories	0
329	G.45.40	Sale, maintenance and repair of motorcycles and related parts and accessories	0
330	G.46.11	Agents involved in the sale of agricultural raw materials, live animals, textile raw materials and semi-finished goods	0
331	G.46.12	Agents involved in the sale of fuels, ores, metals and industrial chemicals	0
332	G.46.13	Agents involved in the sale of timber and building materials	0
333	G.46.14	Agents involved in the sale of machinery, industrial equipment, ships and aircraft	0
334	G.46.15	Agents involved in the sale of furniture, household goods, hardware and ironmongery	0
335	G.46.16	Agents involved in the sale of textiles, clothing, fur, footwear and leather goods	0
336	G.46.17	Agents involved in the sale of food, beverages and tobacco	0
337	G.46.18	Agents specialised in the sale of other particular products	0
338	G.46.19	Agents involved in the sale of a variety of goods	0
339	G.46.21	Wholesale of grain, unmanufactured tobacco, seeds and animal feeds	0
340	G.46.22	Wholesale of flowers and plants	0
341	G.46.23	Wholesale of live animals	0
342	G.46.24	Wholesale of hides, skins and leather	0
343	G.46.31	Wholesale of fruit and vegetables	0
344	G.46.32	Wholesale of meat and meat products	0
345	G.46.33	Wholesale of dairy products, eggs and edible oils and fats	0
346	G.46.34	Wholesale of beverages	0
347	G.46.35	Wholesale of tobacco products	0
348	G.46.36	Wholesale of sugar and chocolate and sugar confectionery	0
349	G.46.37	Wholesale of coffee, tea, cocoa and spices	0
350	G.46.38	Wholesale of other food, including fish, crustaceans and molluscs	0
351	G.46.39	Non-specialised wholesale of food, beverages and tobacco	0
352	G.46.41	Wholesale of textiles	0
353	G.46.42	Wholesale of clothing and footwear	0
354	G.46.43	Wholesale of electrical household appliances	0
355	G.46.44	Wholesale of china and glassware and cleaning materials	0
356	G.46.45	Wholesale of perfume and cosmetics	0
357	G.46.46	Wholesale of pharmaceutical goods	0
358	G.46.47	Wholesale of furniture, carpets and lighting equipment	0
359	G.46.48	Wholesale of watches and jewellery	0
360	G.46.49	Wholesale of other household goods	0
361	G.46.51	Wholesale of computers, computer peripheral equipment and software	0
362	G.46.52	Wholesale of electronic and telecommunications equipment and parts	0
363	G.46.61	Wholesale of agricultural machinery, equipment and supplies	0
364	G.46.62	Wholesale of machine tools	0
365	G.46.63	Wholesale of mining, construction and civil engineering machinery	0
366	G.46.64	Wholesale of machinery for the textile industry and of sewing and knitting machines	0
367	G.46.65	Wholesale of office furniture	0
368	G.46.66	Wholesale of other office machinery and equipment	0
369	G.46.69	Wholesale of other machinery and equipment	0
370	G.46.71	Wholesale of solid, liquid and gaseous fuels and related products	0
371	G.46.72	Wholesale of metals and metal ores	0
372	G.46.73	Wholesale of wood, construction materials and sanitary equipment	0
373	G.46.74	Wholesale of hardware, plumbing and heating equipment and supplies	0
374	G.46.75	Wholesale of chemical products	0
375	G.46.76	Wholesale of other intermediate products	0
376	G.46.77	Wholesale of waste and scrap	0
377	G.46.90	Non-specialised wholesale trade	0
378	G.47.11	Retail sale in non-specialised stores with food, beverages or tobacco predominating	0
379	G.47.19	Other retail sale in non-specialised stores	0
380	G.47.21	Retail sale of fruit and vegetables in specialised stores	0
381	G.47.22	Retail sale of meat and meat products in specialised stores	0
382	G.47.23	Retail sale of fish, crustaceans and molluscs in specialised stores	0
383	G.47.24	Retail sale of bread, cakes, flour confectionery and sugar confectionery in specialised stores	0
384	G.47.25	Retail sale of beverages in specialised stores	0
385	G.47.26	Retail sale of tobacco products in specialised stores	0
386	G.47.29	Other retail sale of food in specialised stores	0
387	G.47.30	Retail sale of automotive fuel in specialised stores	0
388	G.47.41	Retail sale of computers, peripheral units and software in specialised stores	0
389	G.47.42	Retail sale of telecommunications equipment in specialised stores	0
390	G.47.43	Retail sale of audio and video equipment in specialised stores	0
391	G.47.51	Retail sale of textiles in specialised stores	0
392	G.47.52	Retail sale of hardware, paints and glass in specialised stores	0
393	G.47.53	Retail sale of carpets, rugs, wall and floor coverings in specialised stores	0
394	G.47.54	Retail sale of electrical household appliances in specialised stores	0
395	G.47.59	Retail sale of furniture, lighting equipment and other household articles in specialised stores	0
396	G.47.61	Retail sale of books in specialised stores	0
397	G.47.62	Retail sale of newspapers and stationery in specialised stores	0
398	G.47.63	Retail sale of music and video recordings in specialised stores	0
399	G.47.64	Retail sale of sporting equipment in specialised stores	0
400	G.47.65	Retail sale of games and toys in specialised stores	0
401	G.47.71	Retail sale of clothing in specialised stores	0
402	G.47.72	Retail sale of footwear and leather goods in specialised stores	0
403	G.47.73	Dispensing chemist in specialised stores	0
404	G.47.74	Retail sale of medical and orthopaedic goods in specialised stores	0
405	G.47.75	Retail sale of cosmetic and toilet articles in specialised stores	0
406	G.47.76	Retail sale of flowers, plants, seeds, fertilisers, pet animals and pet food in specialised stores	0
407	G.47.77	Retail sale of watches and jewellery in specialised stores	0
408	G.47.78	Other retail sale of new goods in specialised stores	0
409	G.47.79	Retail sale of second-hand goods in stores	0
410	G.47.81	Retail sale via stalls and markets of food, beverages and tobacco products	0
411	G.47.82	Retail sale via stalls and markets of textiles, clothing and footwear	0
412	G.47.89	Retail sale via stalls and markets of other goods	0
413	G.47.91	Retail sale via mail order houses or via Internet	0
414	G.47.99	Other retail sale not in stores, stalls or markets	0
415	H.49.10	Passenger rail transport, interurban	0
416	H.49.20	Freight rail transport	0
417	H.49.31	Urban and suburban passenger land transport	0
418	H.49.32	Taxi operation	0
419	H.49.39	Other passenger land transport n.e.c.	0
420	H.49.41	Freight transport by road	0
421	H.49.42	Removal services	0
422	H.49.50	Transport via pipeline	0
423	H.50.10	Sea and coastal passenger water transport	0
424	H.50.20	Sea and coastal freight water transport	0
425	H.50.30	Inland passenger water transport	0
426	H.50.40	Inland freight water transport	0
427	H.51.10	Passenger air transport	0
428	H.51.21	Freight air transport	0
429	H.51.22	Space transport	0
430	H.52.10	Warehousing and storage	0
431	H.52.21	Service activities incidental to land transportation	0
432	H.52.22	Service activities incidental to water transportation	0
433	H.52.23	Service activities incidental to air transportation	0
434	H.52.24	Cargo handling	0
435	H.52.29	Other transportation support activities 	0
436	H.53.10	Postal activities under universal service obligation	0
437	H.53.20	Other postal and courier activities	0
438	I.55.10	Hotels and similar accommodation	0
439	I.55.20	Holiday and other short-stay accommodation	0
440	I.55.30	Camping grounds, recreational vehicle parks and trailer parks	0
441	I.55.90	Other accommodation	0
442	I.56.10	Restaurants and mobile food service activities	0
443	I.56.21	Event catering activities	0
444	I.56.29	Other food service activities	0
445	I.56.30	Beverage serving activities	0
446	J.58.11	Book publishing	0
447	J.58.12	Publishing of directories and mailing lists	0
448	J.58.13	Publishing of newspapers	0
449	J.58.14	Publishing of journals and periodicals	0
450	J.58.19	Other publishing activities	0
451	J.58.21	Publishing of computer games	0
452	J.58.29	Other software publishing	0
453	J.59.11	Motion picture, video and television programme production activities	0
454	J.59.12	Motion picture, video and television programme post-production activities	0
455	J.59.13	Motion picture, video and television programme distribution activities	0
456	J.59.14	Motion picture projection activities	0
457	J.59.20	Sound recording and music publishing activities	0
458	J.60.10	Radio broadcasting	0
459	J.60.20	Television programming and broadcasting activities	0
460	J.61.10	Wired telecommunications activities	0
461	J.61.20	Wireless telecommunications activities	0
462	J.61.30	Satellite telecommunications activities	0
463	J.61.90	Other telecommunications activities	0
464	J.62.01	Computer programming activities	0
465	J.62.02	Computer consultancy activities	0
466	J.62.03	Computer facilities management activities	0
467	J.62.09	Other information technology and computer service activities	0
468	J.63.11	Data processing, hosting and related activities	0
469	J.63.12	Web portals	0
470	J.63.91	News agency activities	0
471	J.63.99	Other information service activities n.e.c.	0
472	K.64.11	Central banking	0
473	K.64.19	Other monetary intermediation	0
474	K.64.20	Activities of holding companies	0
475	K.64.30	Trusts, funds and similar financial entities	0
476	K.64.91	Financial leasing	0
477	K.64.92	Other credit granting	0
478	K.64.99	Other financial service activities, except insurance and pension funding n.e.c.	0
479	K.65.11	Life insurance	0
480	K.65.12	Non-life insurance	0
481	K.65.20	Reinsurance	0
482	K.65.30	Pension funding	0
483	K.66.11	Administration of financial markets	0
484	K.66.12	Security and commodity contracts brokerage	0
485	K.66.19	Other activities auxiliary to financial services, except insurance and pension funding	0
486	K.66.21	Risk and damage evaluation	0
487	K.66.22	Activities of insurance agents and brokers	0
488	K.66.29	Other activities auxiliary to insurance and pension funding	0
489	K.66.30	Fund management activities	0
490	L.68.10	Buying and selling of own real estate	0
491	L.68.20	Renting and operating of own or leased real estate	0
492	L.68.31	Real estate agencies	0
493	L.68.32	Management of real estate on a fee or contract basis	0
494	M.69.10	Legal activities	0
495	M.69.20	Accounting, bookkeeping and auditing activities; tax consultancy	0
496	M.70.10	Activities of head offices	0
497	M.70.21	Public relations and communication activities	0
498	M.70.22	Business and other management consultancy activities	0
499	M.71.11	Architectural activities 	0
500	M.71.12	Engineering activities and related technical consultancy	0
501	M.71.20	Technical testing and analysis	0
502	M.72.11	Research and experimental development on biotechnology	0
503	M.72.19	Other research and experimental development on natural sciences and engineering	0
504	M.72.20	Research and experimental development on social sciences and humanities	0
505	M.73.11	Advertising agencies	0
506	M.73.12	Media representation	0
507	M.73.20	Market research and public opinion polling	0
508	M.74.10	Specialised design activities	0
509	M.74.20	Photographic activities	0
510	M.74.30	Translation and interpretation activities	0
511	M.74.90	Other professional, scientific and technical activities n.e.c.	0
512	M.75.00	Veterinary activities	0
513	N.77.11	Renting and leasing of cars and light motor vehicles	0
514	N.77.12	Renting and leasing of trucks	0
515	N.77.21	Renting and leasing of recreational and sports goods	0
516	N.77.22	Renting of video tapes and disks	0
517	N.77.29	Renting and leasing of other personal and household goods	0
518	N.77.31	Renting and leasing of agricultural machinery and equipment	0
519	N.77.32	Renting and leasing of construction and civil engineering machinery and equipment	0
520	N.77.33	Renting and leasing of office machinery and equipment (including computers)	0
521	N.77.34	Renting and leasing of water transport equipment	0
522	N.77.35	Renting and leasing of air transport equipment	0
523	N.77.39	Renting and leasing of other machinery, equipment and tangible goods n.e.c.	0
524	N.77.40	Leasing of intellectual property and similar products, except copyrighted works	0
525	N.78.10	Activities of employment placement agencies	0
526	N.78.20	Temporary employment agency activities	0
527	N.78.30	Other human resources provision	0
528	N.79.11	Travel agency activities	0
529	N.79.12	Tour operator activities	0
530	N.79.90	Other reservation service and related activities	0
531	N.80.10	Private security activities	0
532	N.80.20	Security systems service activities	0
533	N.80.30	Investigation activities	0
534	N.81.10	Combined facilities support activities	0
535	N.81.21	General cleaning of buildings	0
536	N.81.22	Other building and industrial cleaning activities	0
537	N.81.29	Other cleaning activities	0
538	N.81.30	Landscape service activities	0
539	N.82.11	Combined office administrative service activities	0
540	N.82.19	Photocopying, document preparation and other specialised office support activities	0
541	N.82.20	Activities of call centres	0
542	N.82.30	Organisation of conventions and trade shows	0
543	N.82.91	Packaging activities	0
544	N.82.92	Activities of collection agencies and credit bureaus	0
545	N.82.99	Other business support service activities n.e.c.	0
546	O.84.11	General public administration activities	0
547	O.84.12	Regulation of the activities of providing health care, education, cultural services and other social services, excluding social security	0
548	O.84.13	Regulation of and contribution to more efficient operation of businesses	0
549	O.84.21	Foreign affairs	0
550	O.84.22	Defence activities	0
551	O.84.23	Justice and judicial activities	0
552	O.84.24	Public order and safety activities	0
553	O.84.25	Fire service activities	0
554	O.84.30	Compulsory social security activities	0
555	P.85.10	Pre-primary education 	0
556	P.85.20	Primary education 	0
557	P.85.31	General secondary education 	0
558	P.85.32	Technical and vocational secondary education 	0
559	P.85.41	Post-secondary non-tertiary education	0
560	P.85.42	Tertiary education	0
561	P.85.51	Sports and recreation education	0
562	P.85.52	Cultural education	0
563	P.85.53	Driving school activities	0
564	P.85.59	Other education n.e.c.	0
565	P.85.60	Educational support activities	0
566	Q.86.10	Hospital activities	0
567	Q.86.21	General medical practice activities	0
568	Q.86.22	Specialist medical practice activities	0
569	Q.86.23	Dental practice activities	0
570	Q.86.90	Other human health activities	0
571	Q.87.10	Residential nursing care activities	0
572	Q.87.20	Residential care activities for mental retardation, mental health and substance abuse	0
573	Q.87.30	Residential care activities for the elderly and disabled	0
574	Q.87.90	Other residential care activities	0
575	Q.88.10	Social work activities without accommodation for the elderly and disabled	0
576	Q.88.91	Child day-care activities	0
577	Q.88.99	Other social work activities without accommodation n.e.c.	0
578	R.90.01	Performing arts	0
579	R.90.02	Support activities to performing arts	0
580	R.90.03	Artistic creation	0
581	R.90.04	Operation of arts facilities	0
582	R.91.01	Library and archives activities	0
583	R.91.02	Museums activities	0
584	R.91.03	Operation of historical sites and buildings and similar visitor attractions	0
585	R.91.04	Botanical and zoological gardens and nature reserves activities	0
586	R.92.00	Gambling and betting activities	0
587	R.93.11	Operation of sports facilities	0
588	R.93.12	Activities of sport clubs	0
589	R.93.13	Fitness facilities	0
590	R.93.19	Other sports activities	0
591	R.93.21	Activities of amusement parks and theme parks	0
592	R.93.29	Other amusement and recreation activities	0
593	S.94.11	Activities of business and employers membership organisations	0
594	S.94.12	Activities of professional membership organisations	0
595	S.94.20	Activities of trade unions	0
596	S.94.91	Activities of religious organisations	0
597	S.94.92	Activities of political organisations	0
598	S.94.99	Activities of other membership organisations n.e.c.	0
599	S.95.11	Repair of computers and peripheral equipment	0
600	S.95.12	Repair of communication equipment	0
601	S.95.21	Repair of consumer electronics	0
602	S.95.22	Repair of household appliances and home and garden equipment	0
603	S.95.23	Repair of footwear and leather goods	0
604	S.95.24	Repair of furniture and home furnishings	0
605	S.95.25	Repair of watches, clocks and jewellery	0
606	S.95.29	Repair of other personal and household goods	0
607	S.96.01	Washing and (dry-)cleaning of textile and fur products	0
608	S.96.02	Hairdressing and other beauty treatment	0
609	S.96.03	Funeral and related activities	0
610	S.96.04	Physical well-being activities	0
611	S.96.09	Other personal service activities n.e.c.	0
612	T.97.00	Activities of households as employers of domestic personnel	0
613	T.98.10	Undifferentiated goods-producing activities of private households for own use	0
614	T.98.20	Undifferentiated service-producing activities of private households for own use	0
615	U.99.00	Activities of extraterritorial organisations and bodies	0
\.


--
-- Data for Name: t_org_ind_reg; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_org_ind_reg (id, name, active, country) FROM stdin;
1	Example 1	1	Ankara
2	Example 2	1	─░stanbul
3	Example 3	1	─░zmir
\.


--
-- Data for Name: t_prcss; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prcss (id, name, name_tr, mother_id, active, layer, description, prcss_family_id) FROM stdin;
1	Forming Processes	┼Şekillendirme S├╝re├ğleri	\N	1	1	\N	\N
2	machining Processes	Tala┼şl─▒ ─░malat ├╝re├ğleri	\N	1	1	\N	\N
3	Casting Processes	D├Âk├╝m S├╝re├ğleri	\N	1	1	\N	\N
4	Joining Processes	Birle┼ştirme S├╝re├ğleri	\N	1	1	\N	\N
5	Molding	Kal─▒p S├╝re├ğleri	\N	1	1	\N	\N
6	Rapid Manufacturing Processes	H─▒zl─▒ Prototip ├£retim S├╝re├ğleri	\N	1	1	\N	\N
7	Other	Di─şer ─░malat S├╝re├ğleri	\N	1	1	\N	\N
8	Forging	D├Âvme	1	1	2	\N	\N
9	Forming and Shaping of Ceramics	Seramik ┼Şekillendirme	1	1	2	\N	\N
10	Powder Metallurgy	Toz Metalurjisi	1	1	2	\N	\N
11	Pressing	S─▒k─▒┼şt─▒rma-Presleme	1	1	2	\N	\N
12	Processing of Plastics and Composite Materials	Plastik ve Kompozit Malzeme ─░mal─▒	1	1	2	\N	\N
13	Rolling	Haddeleme	1	1	2	\N	\N
14	Sheet Metal Forming	Sa├ğ ┼Şekillendirme	1	1	2	\N	\N
15	Cold Sizing	So─şuk Ebatlandirma	1	1	2	\N	\N
16	End Tube forming	Boru ile ┼Şekillendirme	1	1	2	\N	\N
17	Guering Process	Guering ─░┼şleme	1	1	2	\N	\N
18	Hot Metal Gas Forming	S─▒cak Metal Gazlarla ┼Şekillendirme	1	1	2	\N	\N
19	Wheelon Process	Wheelon ─░┼şleme	1	1	2	\N	\N
20	Bending	E─şme	1	1	2	\N	\N
21	Curling	kenar k─▒v─▒rma	1	1	2	\N	\N
22	Decambering	Bombe Giderme	1	1	2	\N	\N
23	Electro Forming	Elektrikli ┼Şekillendirme	1	1	2	\N	\N
24	Extrusion	Ekstr├╝zyon	1	1	2	\N	\N
25	Flanging	kenar b├╝kme	1	1	2	\N	\N
26	Flattering	Flattering	1	1	2	\N	\N
27	Hubbing	─▒stampa ile basma	1	1	2	\N	\N
28	Ironing	incelterek ├ğekme	1	1	2	\N	\N
29	Redrawing	Yeniden ├ğekme	1	1	2	\N	\N
30	Seaming	katlamal─▒ diki┼ş	1	1	2	\N	\N
31	Staking	punta ile per├ğinleme	1	1	2	\N	\N
32	Straightening	do─şrultma	1	1	2	\N	\N
33	Swaging	toka├ğlama	1	1	2	\N	\N
34	Machining Center	Machining Center	2	1	2	\N	\N
35	Turning	Tornalama	2	1	2	\N	\N
36	Milling	Freze	2	1	2	\N	\N
37	Shaping	┼Şekillendirme	2	1	2	\N	\N
38	Drilling	Delme Tz.	2	1	2	\N	\N
39	Broaching	Bro┼şlama- T─▒─ş ├çekme	2	1	2	\N	\N
40	Countersinking	Hav┼şa A├ğma	2	1	2	\N	\N
41	Gashing	Gashing	2	1	2	\N	\N
42	Grinding	Ta┼şlama Tez.	2	1	2	\N	\N
43	Hobbing	K─▒lavuz A├ğma	2	1	2	\N	\N
44	Honning	Honlama- Bileme Tez.n	2	1	2	\N	\N
45	Routing	Routing	2	1	2	\N	\N
46	Sawing	Testere	2	1	2	\N	\N
47	Tapping	k─▒lavuzla d─▒┼ş a├ğma	2	1	2	\N	\N
48	Reaming	Raybalama	2	1	2	\N	\N
49	Planing	Rendeleme	2	1	2	\N	\N
50	Finishing	Perdah	2	1	2	\N	\N
51	Non Traditional Machinig	Geleneksel Olmayan S├╝re├ğler	2	1	2	\N	\N
52	Micro Machining	Mikro Tala┼şl─▒ ─░malat	2	1	2	\N	\N
53	Centrifugal Casting Processes	Santrif├╝jal (Merkez-ka├ğ) D├Âk├╝m S├╝reci	3	1	2	\N	\N
54	Continuous Casting Processes	S├╝rekli D├Âk├╝m S├╝reci	3	1	2	\N	\N
55	Die Casting Processes	Press D├Âk├╝m	3	1	2	\N	\N
56	Evaporative Pattern Casting Processes	Buharla┼şan Model	3	1	2	\N	\N
57	Investment Casting	Eriyen Kal─▒pla D├Âk├╝m	3	1	2	\N	\N
58	Low Pressure	D├╝┼ş├╝k Bas─▒n├ğl─▒	3	1	2	\N	\N
59	Permanent Mold Casting	Daimi Kal─▒p	3	1	2	\N	\N
60	Plastic Mold	Plastik Kal─▒b	3	1	2	\N	\N
61	Resin Casting	Rezin D├Âk├╝m	3	1	2	\N	\N
62	Sand Casting	Kum D├Âk├╝m	3	1	2	\N	\N
63	Shell Casting	Kabuk D├Âk├╝m	3	1	2	\N	\N
64	Slush	Islak Kal─▒b	3	1	2	\N	\N
65	Spray Forming	P├╝sk├╝rt├╝ml├╝ ┼Şekillendirme	3	1	2	\N	\N
66	Adhesive Bonding	Yap─▒┼şkanl─▒ Ba─şlama	4	1	2	\N	\N
67	Brazing	Lehimleme	4	1	2	\N	\N
68	Fastening	Ba─şlama	4	1	2	\N	\N
69	Press Fitting	Bask─▒l─▒ Ge├ğirme	4	1	2	\N	\N
70	Sintering	Peki┼ştirme- Zintrleme	4	1	2	\N	\N
71	Soldering	Lehimleme	4	1	2	\N	\N
72	Welding	Kaynak	4	1	2	\N	\N
73	Plastics	Plastik Kal─▒plar─▒	5	1	2	\N	\N
74	Shrink Fitting	├çekerek Oturtma (Kal─▒pta)	5	1	2	\N	\N
75	Shrink Wrapping	├çekerek Sarma (Kal─▒pta)	5	1	2	\N	\N
76	Fused Deposition Molding	Eritilen Model	6	1	2	\N	\N
77	Laminated Object Manufacturing	Katmanl─▒ Mal ├£retimi	6	1	2	\N	\N
78	Laser Engineered Net Shaping	Hassas Lazerli ┼Şekillendirme	6	1	2	\N	\N
79	Selective Laser Sintering	Se├ğilmeli Lazer Zinterleme	6	1	2	\N	\N
80	Stereo Lithography	Stereo Litografi	6	1	2	\N	\N
81	Three Dimentional Printing	├£├ğ Boyutlu Yazma (Bask─▒)	6	1	2	\N	\N
82	Crushing	S─▒k─▒┼şt─▒rmal─▒- K─▒r─▒c─▒	7	1	2	\N	\N
83	Mill	Haddelemek	7	1	2	\N	\N
84	Mining	Madencilik	7	1	2	\N	\N
85	Wood Working	A─şa├ğ ─░┼şlemen	7	1	2	\N	\N
86	Drop Forge Forging	Drop Forge Forging	8	1	3	\N	\N
87	Forging Cored	doldurma d├Âvmesi	8	1	3	\N	\N
88	Hammer Forge	├ğeki├ğle D├Âvme	8	1	3	\N	\N
89	High Energy Rate Forging	y├╝ksek h─▒zla d├Âvme	8	1	3	\N	\N
90	Incremental Forging	Artan D├Âvme	8	1	3	\N	\N
91	No Draft Forging	s─▒k─▒ payl─▒ d├Âvme	8	1	3	\N	\N
92	Powder Forging	toz d├Âvmesi	8	1	3	\N	\N
93	Press Forging	preste d├Âvme	8	1	3	\N	\N
94	Smith Forging	demirci d├Âvmesi	8	1	3	\N	\N
411	clinker	\N	\N	1	1	\N	1
95	Upset Forging	a├ğ─▒k kal─▒pla y─▒─şarak d├Âvme	8	1	3	\N	\N
96	Compacting and Sintering	S─▒k─▒┼şt─▒rma ve Zinterleme	10	1	3	\N	\N
97	Hot Isostatic Pressing	─░zostatik S─▒cak S─▒k─▒┼şt─▒rma	10	1	3	\N	\N
98	Metal Injection Molding	Metal Enjeksyonlu Kal─▒plama	10	1	3	\N	\N
99	Spray Forming (Molding)	P├╝sk├╝rtmeli ┼Şekillendirme (Kal─▒pta)	10	1	3	\N	\N
100	Deep Drawing	derin ├ğekme	11	1	3	\N	\N
101	Pressing Blanking	Basarak Bo┼şaltma	11	1	3	\N	\N
102	Stretch Forming	gererek ┼şekillendirme	11	1	3	\N	\N
103	Embossing	Kabartma	11	1	3	\N	\N
104	Cold Rolling	So─şuk Haddeleme	13	1	3	\N	\N
105	Cross Rolling	├çapraz Haddeleme	13	1	3	\N	\N
106	Cryo Rolling	Cryo Haddeleme	13	1	3	\N	\N
107	Hot Rolling	S─▒cak Haddeleme	13	1	3	\N	\N
108	Orbital Rolling	Orbital Haddeleme	13	1	3	\N	\N
109	Ring Rolling	Halkal─▒ Haddeleme	13	1	3	\N	\N
110	Shape Rolling	┼şekil Haddeleme	13	1	3	\N	\N
111	Sheet Metal Rolling	Sa├ğ Metal Haddeleme	13	1	3	\N	\N
112	Thread Rolling	Di┼ş Haddeleme	13	1	3	\N	\N
113	Transverse Rolling	Ters Haddeleme	13	1	3	\N	\N
114	Flat Rolling	Yass─▒ Haddeleme	13	1	3	\N	\N
115	Explosive Forming	Patlay─▒c─▒yla ┼Şekillendirme	14	1	3	\N	\N
116	Magnetic Pulse	Magnetik Etki	14	1	3	\N	\N
117	Peening	Peening	14	1	3	\N	\N
118	Spinning	S─▒vama	14	1	3	\N	\N
119	Drawing	├çekme	14	1	3	\N	\N
120	Incremental	Kademli	14	1	3	\N	\N
121	Rubber	Kau├ğuk	14	1	3	\N	\N
122	Sheraing	Kesme	14	1	3	\N	\N
123	Cut Off Parting	Kanal A├ğma	35	1	3	\N	\N
124	Facing	Alin Tornalama	35	1	3	\N	\N
125	Knurling	Kertilkleme	35	1	3	\N	\N
126	Lathe	Torna	35	1	3	\N	\N
127	Spinning	d├Ânerli s─▒vama	35	1	3	\N	\N
128	Boring	Delik ─░┼şleme	35	1	3	\N	\N
129	Shaping Horizontal	Yatay ┼Şekillendirme	37	1	3	\N	\N
130	Special Purpose Shaping	├ûzel Ama├ğl─▒ ┼Şekillendirme	37	1	3	\N	\N
131	Vertical Shaping	Dik ┼Şekillendirme	37	1	3	\N	\N
132	Double Housing	├ğift s├╝tunlu	49	1	3	\N	\N
133	Edgeor Plate Planing	Kenar rendeleme	49	1	3	\N	\N
134	Open Side Planing	A├ğik Kenar Rendeleme	49	1	3	\N	\N
135	Pit Type Planing	Pit Tipi Rendeleme	49	1	3	\N	\N
136	Abrasive Blasting	A┼ş─▒nd─▒r─▒c─▒ P├╝sk├╝rtme	50	1	3	\N	\N
137	Spindle Finishing	─░┼şmilli Perdah	50	1	3	\N	\N
138	Super Finishing	Hassas Perdahlama	50	1	3	\N	\N
139	Vibratory Finishing	titre┼şimli Perdah	50	1	3	\N	\N
140	Wire Brushing	telli f─▒r├ğalama	50	1	3	\N	\N
141	Buffling	Cilalama	50	1	3	\N	\N
142	Burnishing	bask─▒ tak─▒m─▒ veya makaras─▒ ile perdahlama	50	1	3	\N	\N
143	Etching	asitle a┼ş─▒nd─▒rma	50	1	3	\N	\N
144	Linsing	Linsing	50	1	3	\N	\N
145	Plating	kaplama	50	1	3	\N	\N
146	Polishing	polisaj	50	1	3	\N	\N
147	EDM	Elektrik Bo┼şalt─▒ml─▒ ─░┼şleme (EDM)	51	1	3	\N	\N
148	ECM	ECM	51	1	3	\N	\N
149	AFM	AFM	51	1	3	\N	\N
150	USM	USM	51	1	3	\N	\N
151	Abrasive Belt	A┼ş─▒nd─▒r─▒c─▒ Kay─▒┼ş	51	1	3	\N	\N
152	Abrasive Jet Machining	a┼ş─▒nd─▒r─▒c─▒ p├╝sk├╝rt├╝ml├╝ tala┼şl─▒ imalat	51	1	3	\N	\N
153	Bio Machining	Bio Tala┼şl─▒ ─░malat	51	1	3	\N	\N
154	Electro Chemical Grinding	Elektrikli Kimyasal Ta┼şlama	51	1	3	\N	\N
155	Electro Plating	Elektrolizle Kaplama	51	1	3	\N	\N
156	Electro Polishing	Elektro Polisaj	51	1	3	\N	\N
157	Laser Cutting	lazer kesimi	51	1	3	\N	\N
158	Magnetic Field Assissted Finishing	Manyetik Alan Yard─▒m─▒ ile perdahlama	51	1	3	\N	\N
159	Photo Chemical	I┼ş─▒l Kimyasal ─░┼şleme	51	1	3	\N	\N
160	Ultrasonic Machining	Ses ├£st├╝ Dalgalar─▒yla Tala┼ş Alma	51	1	3	\N	\N
161	Chemical	Kimyasal	51	1	3	\N	\N
162	Water Jet Cutting	Su P├╝sk├╝rt├╝ml├╝ Kesme	51	1	3	\N	\N
163	Full Mold Casting	B├╝t├╝n Kal─▒p	56	1	3	\N	\N
164	Lost Foam Casting	Kaybolan K├Âp├╝k	56	1	3	\N	\N
165	Lost Foam Investment Casting	Eriyen K├Âp├╝kl├╝ Hassas D├Âk├╝mn	57	1	3	\N	\N
166	Adhesive alloys	Yap─▒┼şkanl─▒ Ala┼ş─▒mlar	66	1	3	\N	\N
167	Epoxy	Tutkal- Epoksi	66	1	3	\N	\N
168	Miscellaneous	├çe┼şitli- Di─şer	66	1	3	\N	\N
169	Modified Epoxy	De─şi┼şime U─şram─▒┼ş Epoksi	66	1	3	\N	\N
170	Phenolics	Fenolikler	66	1	3	\N	\N
171	Polyurethane	Poli├╝retan	66	1	3	\N	\N
172	Thermo Setting- Thermo Plastic	Termoset-Termoplastik	66	1	3	\N	\N
173	Dip Brazing	Dald─▒rma Lehimleme	67	1	3	\N	\N
174	Furnace Brazing	F─▒r─▒nlamal─▒ Pirin├ğ Kayna─ş─▒	67	1	3	\N	\N
175	Induction Brazing	End├╝ksyon Lehimleme	67	1	3	\N	\N
176	Torch	Me┼şale Lehimleme	67	1	3	\N	\N
177	Clinching	Per├ğinli ├çivileme	68	1	3	\N	\N
178	Nailing	├çivileme	68	1	3	\N	\N
179	Nutand Bolts	Somun ve C─▒vata	68	1	3	\N	\N
180	Pining	─░li┼ştirmek	68	1	3	\N	\N
181	Riveting	Per├ğinleme	68	1	3	\N	\N
182	Screwing	Di┼ş A├ğma- Vidalama	68	1	3	\N	\N
183	Stapling	Z─▒mbalama	68	1	3	\N	\N
184	Stitching	Dikme	68	1	3	\N	\N
185	Dip Soldering	Dald─▒rma Lehimleme (Soldering)	67	1	3	\N	\N
186	Hot Plate Soldering	K─▒zg─▒n Levha Lehimlemesi	67	1	3	\N	\N
187	Induction Solderin	End├╝ksyon Lehimleme	67	1	3	\N	\N
188	Iron Soldering	Demir Lehimleme	67	1	3	\N	\N
189	Oven Soldering	F─▒r─▒nda Lehimleme	67	1	3	\N	\N
190	Ultrasonic Soldering	Ultrason Lehimlemen	67	1	3	\N	\N
191	Wave Soldering	Dalgal─▒ Lehimlemen	67	1	3	\N	\N
192	Arc	Elektrikli Ark Kayna─ş─▒	72	1	3	\N	\N
193	Dielectric	─░├ğy├╝k├╝l Kayna─ş─▒	72	1	3	\N	\N
194	Electromagnetic Welding	Elektromanyetik Kayna─ş─▒	72	1	3	\N	\N
195	Electron Beam Welding	Elektron Demet Kayna─ş─▒	72	1	3	\N	\N
196	Flow Welding	Ak─▒m Kayna─ş─▒	72	1	3	\N	\N
197	Heated Metal Plate	Is─▒nm─▒┼ş Metal Kayna─ş─▒	72	1	3	\N	\N
198	High Frequency Resistance	Y├╝ksek S─▒kl─▒kl─▒ Diren├ğ Kayna─ş─▒	72	1	3	\N	\N
199	Hot Air Welding	S─▒cak Hava Kayna─ş─▒	72	1	3	\N	\N
200	Induction	End├╝ksyon	72	1	3	\N	\N
201	Infrared Welding	K─▒z─▒l├Âtesi Kayna─ş─▒	72	1	3	\N	\N
202	Laser Welding	Lazer Kayna─ş─▒	72	1	3	\N	\N
203	Magnetic Pulse Welding	Manyetik Darbeli Kaynak	72	1	3	\N	\N
204	Oxyfeul Gas	Oxsijen Kayna─ş─▒	72	1	3	\N	\N
205	Percussion (Manufacturing)	Elektrikli ├çarpma Kayna─ş─▒	72	1	3	\N	\N
206	Projection Welding	Projeksiyon Kayna─ş─▒	72	1	3	\N	\N
207	Radio Frequency Welding	Y├╝ksek Frekansl─▒ Kaynak	72	1	3	\N	\N
208	Resistance	Diren├ğ Kayna─ş─▒	72	1	3	\N	\N
209	Seam	Diki┼ş Kayna─ş─▒	72	1	3	\N	\N
210	Solid State Welding	Kat─▒ Durum Kaynaklama	72	1	3	\N	\N
211	Solvent	Eritici Madde Kayna─ş─▒n	72	1	3	\N	\N
212	Thermite	Termit Kayna─ş─▒	72	1	3	\N	\N
213	Ultrasonic Welding	Ses ├ûtesi Kayna─ş─▒	72	1	3	\N	\N
214	Upset Welding	Bas─▒n├ğl─▒ Al─▒n Kayna─ş─▒	72	1	3	\N	\N
215	Blow Molding	Hava Bas─▒n├ğl─▒ Kal─▒plama	73	1	3	\N	\N
216	Compression Molding	Hava Bas─▒n├ğl─▒ Kal─▒plama	73	1	3	\N	\N
217	Dip Molding	Derin Kal─▒plaman	73	1	3	\N	\N
218	Expanded Beam	B├╝y├╝yen Tesp─▒h	73	1	3	\N	\N
219	Extrusion	├çekme	73	1	3	\N	\N
220	Foam	K├Âp├╝kn	73	1	3	\N	\N
221	Injection	Enjeksyon	73	1	3	\N	\N
222	Laminating	Katmanl─▒ Plastik Kal─▒plama	73	1	3	\N	\N
223	Matched Mold	E┼şle┼ştirmeli Kal─▒p	73	1	3	\N	\N
224	Pressure Plug Assist	Bas─▒n├ğ Fi┼şi Yard─▒ml─▒ Kal─▒plar	73	1	3	\N	\N
225	Rotational Molding	D├Âner Kal─▒plama	73	1	3	\N	\N
226	Thermoforming	Is─▒l ┼Şekillendirme	73	1	3	\N	\N
227	Transfer	Aktarmal─▒ Kal─▒plama	73	1	3	\N	\N
228	Vacuum Plug Assist	Vakum Fi┼şi Destekli	73	1	3	\N	\N
229	Edge Runner	┼Şili De─şirmeni	82	1	3	\N	\N
230	Gyratory Crusher	D├Âner (Eksantrik) K─▒r─▒c─▒	82	1	3	\N	\N
231	Jaw Crusher	├çeneli K─▒r─▒c─▒n	82	1	3	\N	\N
232	Rollers	Silinder K─▒r─▒c─▒n	82	1	3	\N	\N
233	Blasting	Dinamitleme	84	1	3	\N	\N
234	Quarrying	Ta┼ş Ocakl─▒─ş─▒	84	1	3	\N	\N
235	Joinery	Do─şrama	85	1	3	\N	\N
236	Drawing Bulging	┼şi┼şirme	119	1	4	\N	\N
237	Drawing Necking	Belverme	119	1	4	\N	\N
238	Drawing Nosing	Burunlama	119	1	4	\N	\N
239	Piercing	Delme-Pirsing	122	1	4	\N	\N
240	Stamping	Damgalama-Pullama	122	1	4	\N	\N
241	Shearing Coning	Konlama	122	1	4	\N	\N
242	Cotter	Kama	180	1	4	\N	\N
243	Groove	Pim Kanal─▒n	180	1	4	\N	\N
244	Quick Release	H─▒zl─▒ A├ğ─▒l─▒p-Ba─şlanan	180	1	4	\N	\N
245	Retaining Rings	Tespit Bilezi─şi	180	1	4	\N	\N
246	Roll	Yuvarlak Pim	180	1	4	\N	\N
247	Tapered	Konik Pim	180	1	4	\N	\N
248	Atomic Hydrogen	Aktif Hidrojen	192	1	4	\N	\N
249	Carbon Arc	Karbon Ark	192	1	4	\N	\N
250	Electroslag	C├╝ruf Alt─▒ Kaynaklamas─▒	192	1	4	\N	\N
251	Flux Cored	Eritken Cekirdekli Ark Kayna─ş─▒	192	1	4	\N	\N
252	Gas Metal	Gazalt─▒ Kayna─ş─▒	192	1	4	\N	\N
253	Gas Tungesten	Gaz ├ûrt├╝l├╝ Volfram Ark Kayna─ş─▒	192	1	4	\N	\N
254	Impregnated Tape	Emdirilmi┼ş Bant	192	1	4	\N	\N
255	Manual Metal	Elle Metal Ark Kayna─ş─▒	192	1	4	\N	\N
256	Plasma Arc	Plazma Ark	192	1	4	\N	\N
257	Plasma MIG	Plazma MIG	192	1	4	\N	\N
258	Regulated Metal Disposition	Ayarl─▒ Metal B─▒rakma	192	1	4	\N	\N
259	Shielded Metal	Korunmal─▒ Me ark Kayna─ş─▒	192	1	4	\N	\N
260	Stud	Saplama Kayna─ş─▒	192	1	4	\N	\N
261	Submerged	Tozalt─▒ Ark Kayna─ş─▒	192	1	4	\N	\N
262	High Frequency	Y├╝ksek Ferekansl─▒	200	1	4	\N	\N
263	Low Frequency	D├╝┼ş├╝k Frekansl─▒	200	1	4	\N	\N
264	Air Acetylene	Hava Asetilen Kayna─ş─▒	204	1	4	\N	\N
265	Methylacetylene Propadiene	Metil Asetilen Propodien	204	1	4	\N	\N
266	Oxy Acetylene	Oksi Asetilen	204	1	4	\N	\N
267	Oxy Hydrogen	Oksi Hidrojen	204	1	4	\N	\N
268	Pressure Gas	Bas─▒n├ğl─▒ Gaz Kayna─ş─▒	204	1	4	\N	\N
269	Bult Welding	U├ğ u├ğa Kaynaklama	208	1	4	\N	\N
270	Shot Welding	Vuru┼ş Kayna─ş─▒	208	1	4	\N	\N
271	Spot Welding	Nokta Kayna─ş─▒	208	1	4	\N	\N
272	Cold Welding	So─şuk Kaynak	210	1	4	\N	\N
273	Diffusion	Yay─▒n─▒ml─▒ Kaynak	210	1	4	\N	\N
274	Explosive	Patlamal─▒ Kaynak	210	1	4	\N	\N
275	Forge Welding	D├Âvmeli Kaynaklama	210	1	4	\N	\N
276	Friction Welding	S├╝rt├╝nmeli Kaynak	210	1	4	\N	\N
277	Inertia	Friksiyon Kayna─ş─▒	210	1	4	\N	\N
278	Roll Welding	Merdane Bas─▒n├ğl─▒ Kaynak	210	1	4	\N	\N
279	Biscuit	Peksimet	235	1	4	\N	\N
280	Morticing	MorticingZ─▒vana A├ğma	235	1	4	\N	\N
281	Wood Working Lapping	Parlatman	235	1	4	\N	\N
282	Piercing Dinking Operation	S├╝sl├╝ Kesme	239	1	5	\N	\N
283	Piercing Lancing	Piercing Lancing	239	1	5	\N	\N
284	Piercing  Nibbing	Piercing  Nibbling	239	1	5	\N	\N
285	Piercing Notching	├ğentik a├ğma	239	1	5	\N	\N
286	Piercing Perforating	Pirsing Perforating	239	1	5	\N	\N
287	Piercing  shaving	t─▒ra┼şlama	239	1	5	\N	\N
288	Pircing Trimming	├ğapak alma	239	1	5	\N	\N
289	Shearing Piercing Cutoff	Shearing Piercing Cutoff	239	1	5	\N	\N
290	Straight Shearing Slitting	Dogrudan Dilme	239	1	5	\N	\N
291	Stamping Leather	Deri	240	1	5	\N	\N
292	Stamping Metal	Metal	240	1	5	\N	\N
293	Stamping Progressive	Kademeli Damgalama	240	1	5	\N	\N
294	Electro Gas	Elektrikli Gaz Kayna─ş─▒	252	1	5	\N	\N
295	Pulsed	Darbeli Gazalt─▒ Kayna─ş─▒	252	1	5	\N	\N
296	Short Circuit	K─▒sadevre Gazalt─▒ Kayna─ş─▒	252	1	5	\N	\N
297	Spray Transfer	P├╝sk├╝rtmeli Aktar─▒m	252	1	5	\N	\N
298	CO2	CO2	268	1	5	\N	\N
299	Flash Butt Welding	Yakma Al─▒n Kayna─ş─▒	269	1	5	\N	\N
300	Hot Press	Sicak Pres Kayna─ş─▒	273	1	5	\N	\N
301	Iso Static Hot Gas	E┼şbas─▒n├ğl─▒ S─▒cak Gaz Kayna─ş─▒	273	1	5	\N	\N
302	Vaccum Furnace	Vakumlu Firin	273	1	5	\N	\N
307	Deneme	\N	\N	1	1	\N	\N
310	test	\N	\N	1	1	\N	\N
311	Yeni Process	\N	\N	1	1	\N	4
312	llll	\N	\N	1	1	\N	1
313	chocolate melting	\N	\N	1	1	\N	5
314	AIR	\N	\N	1	1	\N	1
315	Cleaning	\N	\N	1	1	\N	10
316	LED lighting	\N	\N	1	1	\N	8
317	wastewatertreatment	\N	\N	1	1	\N	11
318	Process1compI	\N	\N	1	1	\N	6
319	process1compG	\N	\N	1	1	\N	3
320	process2compG	\N	\N	1	1	\N	6
321	lighting	\N	\N	1	1	\N	17
322	screening of wood chiops	\N	\N	1	1	\N	17
323	preselecting recovered paper	\N	\N	1	1	\N	17
324	pulping of primary fibres	\N	\N	1	1	\N	3
325	pulping of recovered fibres	\N	\N	1	1	\N	1
326	Paper production	\N	\N	1	1	\N	17
327	Printing	\N	\N	1	1	\N	17
328	Incineration	\N	\N	1	1	\N	1
329	Company	\N	\N	1	1	\N	1
330	Company	\N	\N	1	1	\N	1
331	cutting fluid preparation	\N	\N	1	1	\N	17
332	heating	\N	\N	1	1	\N	17
333	packing	\N	\N	1	1	\N	17
334	general cleaning	\N	\N	1	1	\N	18
335	air compression	\N	\N	1	1	\N	17
336	air cleaning	\N	\N	1	1	\N	17
337	recovery	\N	\N	1	1	\N	17
338	Recovery of used cleaning agent	\N	\N	1	1	\N	17
339	waste water treatment	\N	\N	1	1	\N	17
340	Bobinage des transformateurs	\N	\N	1	1	\N	21
341	Smelting	\N	\N	1	1	\N	3
342	Disposal alu plates	\N	\N	1	1	\N	1
343	purchasing printing plate	\N	\N	1	1	\N	1
344	Smelt─▒ng	\N	\N	1	1	\N	3
345	Heating of grinding room	\N	\N	1	1	\N	8
346	kesim	\N	\N	1	1	\N	1
347	torna	\N	\N	1	1	\N	1
348	s─▒cak ┼şekillendirme	\N	\N	1	1	\N	1
349	s─▒cak d├Âvme	\N	\N	1	1	\N	1
350	kumlama	\N	\N	1	1	\N	1
351	di┼ş a├ğma	\N	\N	1	1	\N	1
352	paketleme	\N	\N	1	1	\N	2
353	Washing	\N	\N	1	1	\N	1
354	electricity supply	\N	\N	1	1	\N	1
355	fabrication window	\N	\N	1	1	\N	1
356	Plate processing	\N	\N	1	1	\N	1
357	Generation wastepaper	\N	\N	1	1	\N	1
358	Disposal cutting fluid	\N	\N	1	1	\N	1
359	Cooling machining	\N	\N	1	1	\N	1
360	Trimming glass	\N	\N	1	1	\N	1
361	Cutting spacer	\N	\N	1	1	\N	1
362	Glass lamination	\N	\N	1	1	\N	1
363	Dissolving	\N	\N	1	1	\N	1
364	ibi process	\N	\N	1	1	\N	4
365	TestProcess	\N	\N	1	1	\N	3
366	domestic water distribution	\N	\N	1	1	\N	1
367	pasteurising	\N	\N	1	1	\N	3
368	CIP pasteurising	\N	\N	1	1	\N	3
369	Sterilisation	\N	\N	1	1	\N	1
370	Heating water	\N	\N	1	1	\N	1
371	Pushing milk	\N	\N	1	1	\N	1
372	Calf feeding	\N	\N	1	1	\N	1
373	Pasteurise cheese milk	\N	\N	1	1	\N	1
374	Disinfection	\N	\N	1	1	\N	1
375	Calves feeding	\N	\N	1	1	\N	1
376	sterlisiation_HOT	\N	\N	1	1	\N	21
377	sterilisation_HOT	\N	\N	1	1	\N	20
378	CIP pasteurising2x	\N	\N	1	1	\N	21
379	Brewing	\N	\N	1	1	\N	1
380	cold sterilisation	\N	\N	1	1	\N	17
381	showering	\N	\N	1	1	\N	17
382	cooling unit	\N	\N	1	1	\N	5
383	plastic waste	\N	\N	1	1	\N	5
384	Clinker Production	\N	\N	1	1	\N	5
386	SNCR	\N	\N	1	1	\N	5
387	Dust Filter	\N	\N	1	1	\N	1
388	roller door closing	\N	\N	1	1	\N	19
389	Brewing	\N	\N	1	1	\N	3
390	Brewing	\N	\N	1	1	\N	3
391	Brewery	\N	\N	1	1	\N	3
392	Brewery	\N	\N	1	1	\N	3
393	Cleaning 2	\N	\N	1	1	\N	1
394	Finishing 2	\N	\N	1	1	\N	3
395	swine feeding	\N	\N	1	1	\N	1
396	Haushaltsverbrauch	\N	\N	1	1	\N	3
397	Energy production	\N	\N	1	1	\N	1
398	petcoke burning	\N	\N	1	1	\N	1
399	MSW transport	\N	\N	1	1	\N	2
400	MSW to RDF Transformation	\N	\N	1	1	\N	8
401	RDF burning	\N	\N	1	1	\N	3
402	Pasteurisierung  + CIP 10000	\N	\N	1	1	\N	1
403	NOx filter	\N	\N	1	1	\N	6
404	Pasteurisierung + CIP 20000	\N	\N	1	1	\N	19
405	NOx SNCR reduction	\N	\N	1	1	\N	6
406	Dust Filter ESP	\N	\N	1	1	\N	6
407	Clinker cement	\N	\N	1	1	\N	1
408	Cement Clinker	\N	\N	1	1	\N	1
409	Clinker production	\N	\N	1	1	\N	1
410	production clinker	\N	\N	1	1	\N	1
412	petcoke	\N	\N	1	1	\N	1
413	co-processing	\N	\N	1	1	\N	1
414	Dust Filter Fabric filter	\N	\N	1	1	\N	6
415	drinking water treatment	\N	\N	1	1	\N	3
416	labor	\N	\N	1	1	\N	1
417	cutting	\N	\N	1	1	\N	1
431	X	\N	\N	1	1	\N	\N
432	X	\N	\N	1	1	\N	\N
433	X	\N	\N	1	1	\N	\N
434	X	\N	\N	1	1	\N	\N
435	X	\N	\N	1	1	\N	\N
436	X	\N	\N	1	1	\N	\N
437	X	\N	\N	1	1	\N	\N
438	X	\N	\N	1	1	\N	\N
439	X	\N	\N	1	1	\N	\N
440	X	\N	\N	1	1	\N	\N
441	X	\N	\N	1	1	\N	\N
442	X	\N	\N	1	1	\N	\N
443	X	\N	\N	1	1	\N	\N
444	X	\N	\N	1	1	\N	\N
445	X	\N	\N	1	1	\N	\N
446	X	\N	\N	1	1	\N	\N
447	X	\N	\N	1	1	\N	\N
448	X	\N	\N	1	1	\N	\N
449	X	\N	\N	1	1	\N	\N
450	X	\N	\N	1	1	\N	\N
451	X	\N	\N	1	1	\N	\N
452	X	\N	\N	1	1	\N	\N
453	X	\N	\N	1	1	\N	\N
454	X	\N	\N	1	1	\N	\N
455	X	\N	\N	1	1	\N	\N
456	X	\N	\N	1	1	\N	\N
457	X	\N	\N	1	1	\N	\N
458	X	\N	\N	1	1	\N	\N
459	X	\N	\N	1	1	\N	\N
460	X	\N	\N	1	1	\N	\N
461	X	\N	\N	1	1	\N	\N
462	X	\N	\N	1	1	\N	\N
463	X	\N	\N	1	1	\N	\N
464	X	\N	\N	1	1	\N	\N
465	X	\N	\N	1	1	\N	\N
466	X	\N	\N	1	1	\N	\N
467	X	\N	\N	1	1	\N	\N
468	X	\N	\N	1	1	\N	\N
469	X	\N	\N	1	1	\N	\N
470	X	\N	\N	1	1	\N	\N
471	X	\N	\N	1	1	\N	\N
472	X	\N	\N	1	1	\N	\N
473	X	\N	\N	1	1	\N	\N
474	X	\N	\N	1	1	\N	\N
475	X	\N	\N	1	1	\N	\N
476	X	\N	\N	1	1	\N	\N
477	X	\N	\N	1	1	\N	\N
478	X	\N	\N	1	1	\N	\N
479	X	\N	\N	1	1	\N	\N
480	X	\N	\N	1	1	\N	\N
481	X	\N	\N	1	1	\N	\N
482	X	\N	\N	1	1	\N	\N
483	X	\N	\N	1	1	\N	\N
484	X	\N	\N	1	1	\N	\N
485	X	\N	\N	1	1	\N	\N
486	X	\N	\N	1	1	\N	\N
487	X	\N	\N	1	1	\N	\N
488	Petcoke subsitution Biogas	\N	\N	1	1	\N	3
\.


--
-- Data for Name: t_prcss_family; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prcss_family (id, name, active) FROM stdin;
1	Main material intensive processes\r\n	1
3	Main energy intensive processes\r\n	1
2	Main auxiliary material intensive processes\r\n	1
4	Main waste generating processes\r\n	1
5	Main emission generating processes\r\n	1
6	Main waste / emission treatment process\r\n	1
7	Main material intensive building processes\r\n	1
8	Main energy intensive building processes\r\n	1
9	Main emission generating building processes\r\n	1
10	Processes with lowest rate of utilization \r\n	1
11	Processes with oldest technology\r\n	1
12	test	1
13	test2	1
14	test3	1
17	undefined	1
18	undefined	1
19	undefined	1
20	undefined	1
21	undefined	1
22	test5	1
23	test6	1
24	test7	1
25	Wahsing	1
26		1
27	test use case	1
\.


--
-- Data for Name: t_prdct; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prdct (id, cmpny_id, name, quantities, ucost, ucostu, tper, qunit) FROM stdin;
26	94	Paper	100000	100000	Euro	Annually	\N
27	96	Newspaper	1500000	-100000	Euro	Annually	\N
7	9	Product of EMGE	\N	\N	\N	\N	\N
8	9	Product name	\N	\N	\N	\N	\N
9	36	Product	\N	\N	\N	\N	\N
10	36	Product 1	\N	\N	\N	\N	\N
11	35	Metal product	\N	\N	\N	\N	\N
13	39	Product Z	\N	\N	\N	\N	\N
14	39	Product A	\N	\N	\N	\N	\N
16	40	Product A	\N	\N	\N	\N	\N
28	97	Heat	1520000	1200	Euro	Annually	\N
19	61	metal parts	\N	\N	\N	\N	\N
29	7	Product 1	100	10	Euro	Monthly	\N
30	13	asd	11	11			\N
31	13	asd	12	12			\N
24	63	aluminium parts	1950	10	Euro	Annually	\N
37	7	test	123	123	Euro	Weekly	gram
36	7	test	1	2	Euro	Weekly	\N
39	3358	Sanding machine	13	0	Euro	Annually	pieces/year
40	3362	somun	10000	0		Annually	pieces/year
41	3362	civata	10000	0		Annually	pieces/year
43	94	test1	29.0040000000000013	345	Euro	Daily	Amper
32	132	aluminium parts	4200	0	Euro	Annually	pieces/year
35	132	plastic parts	600	0	Euro	Annually	pieces/year
44	3383	Table	400	50	CHF		pieces/year
33	132	steel parts	5600	0	Euro	Annually	pieces/year
34	132	titanium parts	300	0	Euro	Annually	pieces/year
38	134	Newspaper	13950	0.100000000000000006	CHF	Annually	to (tons)
46	3390	Saftey glass single	2855	0	CHF	Annually	to (tons)
48	3390	Insulation glass	4160	0		Annually	to (tons)
49	3390	Saftey glass multi	5166	0	CHF	Annually	to (tons)
50	3402	myproduct	1000	0		Daily	volt
51	3401	ProductName	0	0			
52	3404	Meat	0	0			
53	3420	ProductTest1	20000	45	CHF		
54	3406	Fish Feed	54	1000	Dollar	Annually	t
55	3412	Fertilizer	3	10000	Dollar	Monthly	m┬│
57	3424	Aluminium-plates	10000	0		Annually	p
58	3423	Magazine	700000	0			kg
59	3435	Cheese milk	100000	0	CHF		l
60	3438	rawmilk	0	0			
64	3446	processed milk	9349250	0	Euro	Annually	kg
66	3451	Pasteurized Milk	9000000	2	CHF	Annually	kg
67	3460	Bier	220	0		Annually	m┬│
68	3458	Bier	220	0			m┬│
69	3455	Bier	220	0		Annually	m┬│
70	3461	Bier	220	0		Annually	m┬│
71	3456	Bier	220	0		Annually	m┬│
72	3457	Bier	218	29884	CHF	Annually	t
73	3465	Pork	5000	15000	CHF	Annually	kg
76	3467	Gesund dank Bier	15000	10		Annually	kg
77	3468	Bier	220	0		Annually	m┬│
75	3462	Vier Bier	220	0	CHF	Annually	m┬│
\.


--
-- Data for Name: t_prj; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj (id, name, start_date, end_date, status_id, description, active, latitude, longitude, zoomlevel) FROM stdin;
42104	stefan.l schweinisch	2020-11-19	\N	1	Aufzucht von Schweinen f├╝r Fleischproduktion	1	47.05581780841443	7.630011254175737	\N
42096	fallstudie brauerei pn	2020-10-22	\N	1	Optimierung und Verbesserung der Prozesse in der Brauerei Leckerbier	1	47.55922717079952	7.593212302746766	\N
42100	fallstudie dominic	2020-10-01	\N	1	Verbesserung der Herstellung des Original Basler Biers	1	47.54481264000378	7.567089809756804	\N
42102	bierbrauerei mp	2020-10-29	\N	1	Bierbrauen	1	47.5592934541445	7.593172788619995	\N
42106	pr├ñsentation	1970-01-01	\N	1	Pr├ñsentation Klasse	1	47.55910537218529	7.597828849570507	\N
42105	bier vor vier	2020-11-01	\N	1	Herstellungs Prozesse Bier	1	47.55986224473044	7.592520387623689	\N
42107	master 2021 c&e	1970-01-01	\N	1	General Project	1	47.54829085624201	7.614701407953319	\N
42079	case_study	2019-01-16	\N	1	Descriptive case study	1	47.39612308753463	8.543549820313956	\N
42109	eip training participants park	2021-04-26	\N	1	Industrial Symbiosis Identification and Evaluation for the EIP Training Ukraine Participants Park	1	50.470973726014954	30.478576891441524	\N
42090	hotel sleepless	2020-04-22	\N	1	Hotel in the canton of GR	1	46.79458218538536	9.84317560198357	\N
42110	space klinker	1970-01-01	\N	1	Petcoke replaced with RDF	1	47.527407897010434	7.6519772644408945	\N
42089	milk factory laughing cow	2020-04-15	\N	1	milk processing	1	47.53813793397175	7.597851394396353	\N
42103	brauerei claudia	2020-10-29	\N	1	x	1	46.340029889842924	8.662031902652311	\N
42091	clinker production: pre- and co-processing of plastic waste	2020-04-29	\N	2	Pre- and co-processing of refuse derived fuel (RDF) in the clinker production	1	47.50220650233883	8.241541126130775	\N
42092	hotel sleepless final	2020-05-13	\N	1	measures to ..	1	46.80173166827295	9.824780239444303	\N
42093	clinker production: pre- and co-processing of plastic waste (v2)	2020-05-18	\N	1	This is a different Cost Benefit Approach to the Clinker Production: Pre- and co-processing of plastic waste project.	1	47.45914738357005	8.286954480036135	\N
42113	stainz	1970-01-01	\N	1	coloring textiles	1	47.50435814533522	7.635609468673548	\N
42114	textili_industry - wasserr├╝ckspeisung	1970-01-01	\N	2	Wassereinspeisung aus bereits verwendetem Produktionswasser	1	47.472856091021896	7.588461719039312	\N
42112	industrielle netzwerke 2021	2021-11-17	\N	2	Fallstudie 2021	1	36.305718311413806	67.3625195163303	\N
45	geneva virtual case	2015-05-05	\N	3	Industrial ecology project based on former work on industrial symbiosis in Geneva\r\nGeographic scale: all industrial areas Geneva	1	46.187109969463876	6.128675937652588	5
42098	stefan.l brauerei	2020-10-29	\N	2	Projekt zur Verbesserung der Effizienz des Bierbrauprozesses im Sinne der Cleaner Production Methode und von Industriellen Symbiosen	1	47.55929709437554	7.593172788619995	\N
42099	bierbrauerei	2020-10-29	\N	1	Bierbrauerei	1	47.559356047983876	7.593217457430765	\N
42108	hotel sleepless 2021	1970-01-01	\N	1	Hotel which is sleepless	1	47.325602198724766	8.534174579244093	\N
42077	milk example	2018-12-03	\N	1	Demonstration of CP and Is measures	1	46.69784990014488	8.452587588410893	\N
42101	josip bierbrauerei	2020-10-29	\N	1	x	1	47.534862411747824	7.641931836321882	\N
\.


--
-- Data for Name: t_prj_acss_cmpny; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_acss_cmpny (cmpny_id, prj_id, read_acss, write_acss, delete_acss) FROM stdin;
\.


--
-- Data for Name: t_prj_acss_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_acss_user (user_id, prj_id, read_acss, write_acss, delete_acss) FROM stdin;
\.


--
-- Data for Name: t_prj_cmpny; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_cmpny (prj_id, cmpny_id) FROM stdin;
42079	3423
42079	3424
42079	3475
42109	3481
42109	3478
42109	3479
42109	3476
42109	3480
42109	3477
42100	3458
42089	3446
42102	3460
42091	3447
42091	3448
42093	3448
42099	3457
42112	3500
42112	3498
42112	3496
42112	3486
42112	3491
42112	3489
42112	3490
42112	3485
45	135
45	3369
45	3368
45	3378
45	3374
45	66
45	3375
45	3373
45	139
45	3376
45	67
45	3365
45	3370
45	3366
45	3372
45	138
45	3367
45	136
45	3364
45	137
42108	3472
42110	3472
42110	3474
42090	3447
42096	3455
42077	3422
42077	3419
42096	3466
42092	3447
42092	3448
42105	3467
42105	3462
\.


--
-- Data for Name: t_prj_cnsltnt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_cnsltnt (prj_id, cnsltnt_id, active) FROM stdin;
42096	28	1
42096	48263	1
42096	48259	1
42096	48262	1
42096	48260	1
42100	28	1
42100	48263	1
42091	48250	1
42091	48245	1
42100	48259	1
42091	28	1
42091	48249	1
42091	48251	1
42092	48250	1
42092	48245	1
42092	28	1
42092	48249	1
42092	48251	1
42093	28	1
42093	48251	1
42112	48300	1
42112	48302	1
42102	28	1
42102	48263	1
42102	48261	1
42102	48257	1
42102	48259	1
42102	48262	1
42102	48260	1
42102	48264	1
42102	48258	1
42112	48298	1
42112	48297	1
42112	48299	1
42112	48294	1
42112	48296	1
42112	48304	1
42112	48292	1
42112	48295	1
42112	48291	1
42112	48293	1
42105	28	1
42105	48263	1
42105	48261	1
42105	48257	1
42105	48259	1
42105	48262	1
42105	48260	1
42105	48264	1
42104	28	1
42105	48258	1
42099	28	1
42099	48263	1
42099	48261	1
42099	48257	1
42099	48259	1
42099	48262	1
42099	48260	1
42099	48264	1
42099	48258	1
42108	28	1
42108	48270	1
42108	48271	1
42090	48250	1
42090	48249	1
42079	48230	1
42079	28	1
42079	48234	1
42089	28	1
42089	48247	1
42089	48246	1
42109	28	1
42109	48272	1
42109	48238	1
42109	48273	1
42109	48241	1
42109	48279	1
42109	48276	1
42077	48245	1
42077	28	1
42077	48248	1
42077	1	1
42109	48283	1
42109	48282	1
42109	48284	1
42109	48216	1
42109	48277	1
45	28	1
45	32	1
45	1	1
45	33	1
45	36	1
42109	48274	1
42109	48278	1
42109	48275	1
42109	48285	1
42109	48281	1
42109	48280	1
42108	48268	1
42108	48265	1
42108	48269	1
42110	48265	1
42110	48245	1
42110	28	1
42110	48268	1
42110	48269	1
\.


--
-- Data for Name: t_prj_cntct_prsnl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_cntct_prsnl (prj_id, usr_id, description) FROM stdin;
21	32	\N
2	1	\N
42049	1	\N
42096	48259	\N
42100	48263	\N
42102	48262	\N
42051	35	\N
42098	28	\N
17	32	\N
42052	35	\N
41	35	\N
42055	1	\N
42056	35	\N
42106	48263	\N
42105	48261	\N
42099	48258	\N
42107	48266	\N
16	35	\N
42108	28	\N
42059	1	\N
42079	48230	\N
40	1	\N
37	33	\N
39	33	\N
42	32	\N
19	32	\N
36	28	\N
43	1	\N
35	35	\N
46	36	\N
47	36	\N
42109	48272	\N
25	32	\N
14	1	\N
42063	48207	\N
45	36	\N
42111	48269	\N
44	28	\N
42065	48205	\N
42066	48216	\N
42110	48269	\N
42070	48228	\N
42071	48228	\N
42073	28	\N
42074	28	\N
42113	48299	\N
42075	28	\N
42076	48230	\N
42078	48230	\N
42114	48301	\N
42072	48230	\N
42112	28	\N
42083	48236	\N
42080	48235	\N
42081	48239	\N
42084	48240	\N
42085	48239	\N
42086	48242	\N
42082	48241	\N
42087	48244	\N
42088	48244	\N
42090	48249	\N
42089	48246	\N
42077	28	\N
42091	48245	\N
42092	48249	\N
42093	48245	\N
42094	48248	\N
42095	48248	\N
42097	48248	\N
42101	48257	\N
42103	48264	\N
42104	48260	\N
\.


--
-- Data for Name: t_prj_doc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_doc (doc_id, prj_id) FROM stdin;
\.


--
-- Data for Name: t_prj_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_prj_status (id, name, name_tr, active, short_code) FROM stdin;
1	Envisioning	\N	1	env
2	Planing	\N	1	pln
3	Development	\N	1	dev
4	Stabilization	\N	1	sta
5	Deployment	\N	1	dep
\.


--
-- Data for Name: t_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_role (id, name, name_tr, active, short_code) FROM stdin;
1	Consultant	Consultant	t	CNS
2	Visitor	Visitor	t	VST
3	Admin	Admin	t	ADM
4	Department Manager	Departman M├╝d├╝r├╝	t	DM
5	Department Worker	Departman ├çal─▒┼şan─▒	t	D├ç
\.


--
-- Data for Name: t_sector; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_sector (id, name, active) FROM stdin;
\.


--
-- Data for Name: t_sector_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_sector_activity (id, sector_id, activity_id) FROM stdin;
\.


--
-- Data for Name: t_state; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_state (id, name, active) FROM stdin;
1	Solid	1
2	Liquid	1
3	Gas	1
\.


--
-- Data for Name: t_synergy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_synergy (id, name, active) FROM stdin;
1	All IS Candidates	1
2	Input Mutualisation	1
3	Output Mutualisation	1
4	Input & Output Mutualisation	1
5	Substitution	1
6	Substitution & Mutualisation	1
\.


--
-- Data for Name: t_transport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_transport (id, name, active) FROM stdin;
\.


--
-- Data for Name: t_transportation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_transportation (id, name, active) FROM stdin;
\.


--
-- Data for Name: t_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_unit (id, name, name_tr, active, unit_type_id) FROM stdin;
1	mg	\N	1	1
2	g	\N	1	1
3	kg	\N	1	1
4	t	\N	1	1
5	kJ	\N	1	1
6	MJ	\N	1	1
7	GJ	\N	1	1
8	kWh	\N	1	1
9	MWh	\N	1	1
10	GWh	\N	1	1
11	mm	\N	1	1
12	cm	\N	1	1
13	m	\N	1	1
14	km	\N	1	1
15	mm┬▓	\N	1	1
16	cm┬▓	\N	1	1
17	m┬▓	\N	1	1
18	mm┬│	\N	1	1
19	cm┬│	\N	1	1
20	m┬│	\N	1	1
21	Nm┬│	\N	1	1
22	l	\N	1	1
23	p	\N	1	1
24	unit	\N	1	1
25	g Nox (as NO2)	\N	1	1
26	tonnes*km	\N	1	1
27	person*km	\N	1	1
28	unit	\N	1	1
29	ha	\N	1	1
30	meal	\N	1	1
\.


--
-- Data for Name: t_unit_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_unit_type (id, name, active) FROM stdin;
1	Production	1
2	Finance	1
3	Period	1
\.


--
-- Data for Name: t_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_user (id, name, surname, user_name, psswrd, role_id, title, phone_num_1, phone_num_2, fax_num, email, description, linkedin_user, photo, active, random_string, click_control, industrial_zone_id, department_id) FROM stdin;
48242	Modul	FHNW	ceosparrii	8a8b550da66e718a1ebd904d78415444	1	Professor	77777777777	77777777777	77777777777	m_gerber@eblcom.ch	Description	\N	default.jpg	\N	\N	\N	0	0
48232	Bob	Bobi	test49	241db62d4cb712d490d6c6fdd81c4682	1	TESTER				test@test.com	Developer	\N	48232.jpg	\N	\N	\N	0	0
48230	Aur├®lie	Stamm	aureliesofies	53f63638a163ca95a685eed09a3a23f4	1	Sofies	0774128203			aurelie.stamm@sofiesgroup.com		\N	default.jpg	\N	\N	\N	0	0
48243	Eberhard	Yves	eberhary	f7f26f4004072afb462f3ae191fd4ce0	2	Master Student				yves.eberhard@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48228	Epp	Alexandre	alexandre	1831438a76e5fcbd2cacf627aa5d57fc	1	Engineer	+41792652943			alexandre.epp@bg-21.com		\N	48228.jpg	\N	0ojgppDg0HskclW98RFW	1	0	0
48231	Salam	Kaddouh	salam	ff7819a440895ff4ad98fc302d2863ca	2	Consultant	+447780331591			salam.kaddouh@sofiesgroup.com		\N	default.jpg	\N	\N	\N	0	0
48251	Eberhard	Yves	yvese	f7f26f4004072afb462f3ae191fd4ce0	1	Student				yves.eberhard@hotmail.ch		\N	48251.jpg	\N	\N	\N	0	0
39	erkman	surren	serkman	e10adc3949ba59abbe56e057f20f883e	2	President	123123123123	123123123123	123123123123	guillaume.massard@gmail.com	Desc	\N	default.jpg	\N	\N	\N	0	0
36	Pierre	Dufaut	consultanttest	7e8d29718f5f42bb2c0c8053f60d67d2	1	Consultant	+41 78 625 27 51	+41 22 338 15 24	+41 22 338 15 30	guillaume.massard@gmail.com	Consultant for the state of GEneva	\N	default.jpg	\N	\N	\N	0	0
48244	John	Doe	johndoe	1a72b36d935a23ab772f497f28464d3f	1	Service Tester	123456	123456		johndoe@omg.com	Testing since years!	\N	48244.jpg	\N	wb246TNk6HM9SEw686ya	1	0	0
32	Emily	Vuylsteke	emily_vuylsteke	eac074b0503b45740d49b18eb659bcfc	1	Consultant	+41764084068	+21223381524	+21223381524	emily.vuylsteke@sofiesonline.com	test	\N	default.jpg	\N	\N	\N	0	0
48233	bob	bobi	bob11	2f771d79f5929f2231b07ea48008a554	2	bobber	12324	1234	1234	bob1@bob.com	12awdawdaw	\N	48233.jpg	\N	\N	\N	0	0
35	Catherine	Moser	catherinemoser	b7c4f77339383a3fbb7799f136432e47	1	Engineer	000000000	0000000000	0000000000	catherine.moser@fhnw.ch	000	\N	default.jpg	\N	\N	0	0	0
48234	Nicole Sulzberger	Sulzberger	nsulzberger	16d7a4fca7442dda3ad93c9a726597e4	1	Developer	0443951170			nicole.sulzberger@ebp.ch		\N	default.jpg	\N	\N	\N	0	0
48245	Basil	Gisi	bgisi	8e607a4752fa2e59413e5790536f2b42	1	Developer & Tester				basil.gisi@fhnw.ch		\N	default.jpg	\N	\N	0	0	0
48239	Andy	Portmann	andyport	9ced30f42861fb5cde765b6a61fbb4d6	1	Chemist	0764539295			andreas.portmann1@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48252	Reimann	Xander	xandalf	38d28ba96c0bc0c07adeea02533086ce	2	Zivi				xandalf23@gmail.com		\N	default.jpg	\N	\N	\N	0	0
48236	Oliver	Heilmann	holiver1991	b43721c40fad4205ace92ac49edc6e9e	1	Consultant				oliver.heilmann@students.fhnw.ch		\N	48236.jpg	\N	\N	\N	0	0
48240	Livia	Engel	liviaengel	e112273bbb666fa18e58dacc84915ea9	1	Student	038783727283	03736484949	03839303030	livia.engel@students.fhnw.ch	333	\N	default.jpg	\N	\N	\N	0	0
48254	Xander	Reimann	xandalf3	38d28ba96c0bc0c07adeea02533086ce	2	Student				xandernikolaj.reimann@fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48263	Jaggi	Dominic	dominicjaggi	040822b27c097fd637e0afe1a03f96c8	1	Students				dominic.jaggi@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48249	Dominic	Renfer	dominic	19f32c70426174b0fcb4df61c81dc453	1	Student				dominic.renfer@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48247	Margaret	Wiltshire	margaret	88e9519abe7b300f46c44194fd0401d8	1	Student				margaretann.wiltshire@students.fhnw.ch		\N	48247.jpg	\N	\N	\N	0	0
48255	yxyxyx	yxyxyxy	fhnwxyxy	7faa9926d150b4da6473b05fbb6fa339	2	Boss	89654854			xyxy@fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48250	Anika	Sidler	anika	522d28b8d02ccc4a740edf2f9ce71f0c	1	Student FHNW				anika.sidler@students.fhhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48262	Pulfer	Michael	michaelp	4682e0709225e37ef21335bdbb3f78e0	1	Student Umwelttechnik FHNW				michael.pulfer@besonet.ch		\N	default.jpg	\N	\N	\N	0	0
48259	Pascal	N├ñf	pnaef	75b2fed850b1508d5e5317d479ccbaf9	1	Student				pascal.naef@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48261	Joel	Trummer	joelt	38b77770a255966b40d9df6a04124eec	1	Student				joel.trummer@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48271	Michael	Burri	michaelburri	c20871c46002401f71b56919d383540e	1	Chef				michael.burri@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48257	Josip	Sebesic	josip	72c818462e4fb8f50bddeaf26bd4ff77	1	Student				josip.sebesic@students.fhnw.ch		\N	default.jpg	\N	7gXyvx8JiN7ehkXSgZ47	1	0	0
48267	Jonas	Jost	jonasj	73d6fdb7e6e1bdb30970b7b273243c57	1	Student				jonas.jost@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48265	Balet	J├®r├®my	jeremy	a8f675bf2becc64db6838312c799617f	1	Student				jeremy.balet@hotmail.com		\N	default.jpg	\N	\N	\N	0	0
48269	Ma├½l	Cantini	maelcantini	dd4585b3505aeabf30863187026b7e92	1	Master student Environmental Technologies FHNW				mael.cantini@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48278	Sergii	Plashykhin	plashykhin	7cbb3252ba6b7e9c422fac5334d22054	1	ºòº║ªüº┐ºÁªÇªé ºáºòºğºÆ				s.plashykhin@recpc.org		\N	default.jpg	\N	\N	\N	0	0
48272	Miro	Meister	mmeister	9324655e89a97ce5dbcdae739683640a	1	Zivi				miro.meister@uzh.ch		\N	default.jpg	\N	\N	\N	0	0
48280	Kostyantyn	Tadlya	kostyantyn	b38fdb2a0e17711e43b3b7969b6f73d8	1	Consultant				kostiantin@recpc.org		\N	48280.jpg	\N	\N	\N	0	0
48282	Nataliia	SHEVCHUK	nata520522	62cc2d8b4bf2d8728120d052163a77df	1	PhD, docent	+380936024299			nata520522@gmail.com		\N	default.jpg	\N	\N	\N	0	0
48274	Roman	Protsak	romanpr	e7cad260001fc67f2182e62ae3d75e98	1	Owner	0679133333	0682288888		office@pr-group.in		\N	default.jpg	\N	\N	\N	0	0
48276	Andrii	Vorfolomeiev	andrii	37b4e2d82900d5e94b8da524fbeb33c0	1	Director				a.vorfolomeiev@recpc.org		\N	48276.jpg	\N	\N	\N	0	0
48284	Ella	Dmytrochenkova	elladmytrochenkova	9711e114200425e6efe5365e94959182	1	expert	0502057931			elladmitrochenkova@gmail.com		\N	default.jpg	\N	\N	\N	0	0
48286	Tetiana	Dehodia	tania	cc8a08f2f13cf20f992d7e8d63e52f09	1	RECP Expert				t.degodia@recpc.org		\N	default.jpg	\N	\N	\N	0	0
48288	Olexiy	Tchaykovsky	olexiytc	6fcdad9b3c7ef38d002588649ef7b892	2	Projects coordinator	+380632413731			olexiytc@yahoo.co.uk		\N	default.jpg	\N	\N	\N	0	0
48289	Urs	Eggenberger	fachstellesr	aee867f25c7b0433968710283745758f	2	Head of Competence Centre SR				usse@geo.unibe.ch		\N	default.jpg	\N	\N	\N	0	0
48229	Dirk	Hengevoss	dirktest	952ba06b78f5f4f29faab9c2f6a522ff	2	Tester	xx	xx	xx	saludos_dirk@gmx.ch		\N	default.jpg	\N	\N	\N	0	0
48305	Tobias	Stebner	stebner	138f5b2ed62fd61e23427fbc0b80f467	2	Student				tobias.stebner@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48301	Frei	Yanick	yanickfrei	d579d6fa42bdfdf06ca3ee6c82f1716c	1	Student				yanick.f@hotmail.com		\N	default.jpg	\N	\N	\N	0	0
48238	Andelina	Jovanovic	angie	2be87818f245e3b0ccab995db617e305	1	student				jov.andelina@gmail.com		\N	48238.jpg	\N	\N	\N	0	0
48237	Giovanni	Desiderio	giogio93	e8329b995c2beb8af35283362552bbef	1	Student				giovanni.desiderio@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
28	Dirk	Hengevoss	fhnwuser	8287458823facb8ff918dbfabcd22ccb	1	Sustainable Ressourcemanagment	0041612285598	0041612285598	0041612285598	dirk.hengevoss@fhnw.ch	Senior Research Associate at FHNW	\N	28.jpg	\N	\N	0	0	0
48253	Reimann	Xander	xandalf2	38d28ba96c0bc0c07adeea02533086ce	1	Student				x.reimann@stud.unibas.ch		\N	default.jpg	\N	\N	\N	0	0
48241	Andelina	Jovanovic	angie213	5af57880db8843d768b700bd5cdbc03c	1	student	1232432	314324321	341312432	aivaovic@gmail.com		\N	48241.jpg	\N	\N	\N	0	0
48235	Markus	Gerber	marger	8778cf652db78c07b454348a8ff3d627	1	Student				markus.gerber1@students.fhnw.ch		\N	48235.jpg	\N	\N	\N	0	0
48248	Reimann	Xander	user123	62cc2d8b4bf2d8728120d052163a77df	1	Consultant				xyo@xy.com	Login for demonstration	\N	48248.jpg	\N	\N	\N	0	0
48207	Monika	Raugeviciute	monika	09ffa3805b7b64c8c4fecddeff2d9280	1	x	1	1	1	monika.raugeviciute@gmail.com	x	\N	default.jpg	\N	5yNpPOInL0KKDtnDD3zD	1	0	0
48205	Daina	Kliaugaite	daina	8287458823facb8ff918dbfabcd22ccb	1	researcher	+37061007892			dainiote@gmail.com	Researcher at Kaunas University of Technology	\N	default.jpg	\N	EdDEYO7nTtcsMEY7sl24	1	0	0
48216	Ingrida	Ingstu	ingstu	15fba3916e4d60edea44414351545400	1	In┼¥inerija				ingridastuopyte@gmail.com		\N	default.jpg	\N	\N	\N	0	0
48256	xyxy	xyxy	fhnwtestuser3	62cc2d8b4bf2d8728120d052163a77df	1	yx				xyxy@gmail.com		\N	default.jpg	\N	\N	\N	0	0
33	Massard	Guillaume	gmassard	7e8d29718f5f42bb2c0c8053f60d67d2	1	BG Consulting Engineers - Business Unit Manager - Building, energy and territory	+41786252751	+ 41 78 625 27 51	xxx	guillaume.massard@bg-21.com	ECOMAN developer	\N	33.jpg	\N	\N	\N	0	0
48246	Valentina	Lombardo	valentina	f9084c4b4cf3be5ed43dd9832c4cf636	1	Student				valentina.lombardo@students.fhnw.ch	MSc Environmental Technology	\N	48246.jpg	\N	\N	\N	0	0
48260	Stefan	Lehmann	stefanlehmann18	5c57b47236a11e059b915dcc1af59c1f	1	Student				stefan.lehmann@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48258	Yves	Saladin	saladin	e5da1f569ab0d8b48241ea13cbf3641d	1	BSc in Life Science Student				yves.saladin@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48275	Sergiy	Filatov	sfilatov	767111095019442305a78332d22ac3e7	1	NIOCHIM				niochim.marketing@gmail.com		\N	48275.jpg	\N	\N	\N	0	0
48264	Steiner	Claudia	claudia	094bd4d2167c9ee70fab93e2cec2660e	1	Student				claudia.steiner@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48268	F├íbio	Ribeiro	fabioribeiro	fad8660674d90781b54760a21a7f520a	1	Student				fabio.darocharibeiro@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48266	Mundt	Raphael	fhnwraphaelmundt	599710d2ded840adf0c8c38687119afe	1	Student				dreck@tuta.io		\N	default.jpg	\N	\N	\N	0	0
48270	Maximilian	Rose	mrose	248e8ff2bbfd377e5802c137a13b0547	1	Student				maximilian.rose@students.fhnw.ch		\N	48270.jpg	\N	\N	\N	0	0
48273	Miro A.	Meister	miromeister	9324655e89a97ce5dbcdae739683640a	1	Zivi				miro.achilles.meister@gmx.ch		\N	default.jpg	\N	\N	\N	0	0
48295	Rohrbach	Rina	rinarohrbach	c382e03011940e5a78d66d11adafc5bf	1	Student				rina.rohrbach@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48279	Mykhailo	Turianytsia	mturyanytsaukr	11df64e5aab8febfb46d0ffc85a894f4	1	Translator/Interpreter				m.turyanytsa@gmail.com		\N	48279.jpg	\N	\N	\N	0	0
48277	Ivan	Omelchuk	ivan37	a6f41e706190ca516716454c8ea3aadd	1	Regional coordinator	0502028601			omelchukivan@gmail.com		\N	48277.jpg	\N	\N	\N	0	0
48283	Nataliia	Borodina	ignsborodina	4fab41f9e0c823ccc4513eb03d20f7bc	1	Bilotserkivsky Institute of Continuous Professional Education	+380508201319			ignsborodina@gmail.com	D.Sc. in Civil Safety, Ph.D. in Ecological Safety. Areas of activity: protection of persons and property; occupational health and safety; environmental management.	\N	48283.jpg	\N	\N	\N	0	0
48281	Vasyl	Martyshko	vasyl123	a355e46d3e5e01a8ac8830d285922cb6	1	12345				vasyl123@email.com		\N	48281.jpg	\N	\N	\N	0	0
48287	Sergey	Kirakosyan	kasjan71	e263c0511ea35d5a0965d23ccb648530	2	ºíonsultant				kasjan71@gmail.com		\N	default.jpg	\N	\N	\N	0	0
48285	Nadiia	Shmygol	nadiiashmygol	b40b4d1c35fa5d50f2a00041f5e20ea6	1	RECPC	+380677209707			nadezdash@ua.fm		\N	48285.jpg	\N	\N	\N	0	0
48290	Mirco	Blaser	mircoblaser	cd1e6f4cafdf373f4c25a4402b1221b9	2	Sci-Assistant				mirco.blaser@fhnw.ch		\N	48290.jpg	\N	\N	\N	0	0
48293	Sch├╝pbach	Cl├®ment	clement	094bd4d2167c9ee70fab93e2cec2660e	1	Student				clement.schuepbach@students.fhnw.ch		\N	48293.jpg	\N	\N	\N	0	0
48297	Dominik	Janik	dominik25	4667a176069dad30ddcf650e5e2e5de1	1	Student				dominik.janik@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48294	Emanuel	Schneiter	emanuel	094bd4d2167c9ee70fab93e2cec2660e	1	student	+41764462531			emanuel.schneiter@students.fhnw.ch		\N	48294.jpg	\N	\N	\N	0	0
48292	Philippe	Langer	planger	23ef13d9d76aaf41cd7f30c1f8eda7d0	1	Student	0763355498			philippe.langer@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48296	Maglaras	Nike	nikema	dd69b9b35e14b6c74ba0513977f46590	1	Student				nike.maglaras@students.fhnw.ch		\N	48296.jpg	\N	\N	\N	0	0
48298	Bj├Ârn	Ramaswamy	moonbaer	2652f0038f7d52de3c9b54094869939e	1	Student				bjoern.ramaswamy@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48291	Samuel	Held	sirheldsamuel	c3a874b69da2f01e943b5a35037c5e64	1	Student				samuel.held@students.fhnw.ch		\N	48291.jpg	\N	FU1raTK8wtDuVrzptaIT	1	0	0
48299	Donna	Karedan	donsrose	1c3d0e7592566a66ab971f061f643ef1	1	Student				donna.karedan@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48302	Benjamin	B├╝hlmann	benjaminbue	a0d151e6ac8d8c6fac9fbfbffc3b8812	1	Student	+41792387724			benjamin.buehlmann@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
48303	S├ñmi	Held	samtheman	a1143d0b9d407156ac18a273a1eb6f76	1	Student				samheld98@gmail.com		\N	default.jpg	\N	\N	\N	0	0
48300	Alessia	B├ñrtsch	alessia	2cc6e9d6f75289da8ab2a9574ee6c3e2	1	Student				alessia.baertsch@students.fhnw.ch		\N	default.jpg	\N	J8WHPi4avNdfSDOA6Go1	1	0	0
48304	Micha	Wehrli	trutelaryjori	11dc9babbb4720de83f77d549dde534d	1	Student				micha.wehrli@students.fhnw.ch		\N	default.jpg	\N	\N	\N	0	0
1	Tuna  Çağlar 	Gümüş	tcgumus	8287458823facb8ff918dbfabcd22ccb	1	Systems Engineer	00905552010103			tunacaglargumus@gmail.com	Everything about computers	\N	1.jpg	f	\N	0	0	0
\.


--
-- Data for Name: t_user_ep_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_user_ep_values (user_id, ep_value, flow_name, primary_id, ep_q_unit) FROM stdin;
28	20	test3	4	0
28	20	test3	9	0
28	100	glasstest	14	0
48230	10	test1	16	0
28	222	salt1	17	0
28	2610	Sterilisation chemical	18	0
28	2610	Sterilisation chemical	19	0
28	2610	Sterilisation chemical	20	0
28	4.1980000000000004	Water and Wastewater CH	21	0
28	4.1980000000000004	Water and Wastewater CH	22	0
28	3522	Raw milk	23	0
28	5945	Phosphoric acid	24	0
28	1583	Sodium hydroxide	25	0
28	1583	Sodium hydroxide	26	0
28	3522	Raw_milk	27	0
28	1583	Sodium_hydroxide	28	0
28	2610	Sterilisation chemical	29	0
28	1583	Sodium_hydroxide	30	0
28	5945	Phosphoric_acid	31	0
28	3522	Raw_milk	32	0
28	509.800000000000011	Electricity_LV_RER	33	0
28	4.1980000000000004	Water_and_Wastewater CH	34	0
28	2610	Sterilisation_chemical	35	0
28	4.1980000000000004	Water_and_Wastewater_CH	36	0
28	1583	Sodium hydroxide	37	0
28	3522	raw_milk	38	0
28	5945	phosphoric_acid	39	0
28	1583	sodium_hydroxide	40	0
28	136.099999999999994	district_heat_mswi	41	0
28	2610	sterilisation_chemical	42	0
28	4.1980000000000004	water_and_wastewater_ch	43	0
28	509.800000000000011	electricity_lv_rer	44	0
28	0.446000000000000008	wastewater	45	0
28	2610	sterilisation_chemical	46	0
28	1583	sodium_hydroxide	47	0
28	5945	phosphoric_acid	48	0
28	3522	rawmilk	49	0
28	509.800000000000011	electricity_fossil	50	0
28	3.75300000000000011	water	51	0
28	136.099999999999994	heat_mswi	52	0
28	3594.19000000000005	rawmilk_losses	53	0
48230	3528.42053686969984	paper	55	0
48230	231.312493578019996	electricity_ch	56	0
48230	9040.86342089440041	aluminium	57	0
48235	0.00375299999999999983	water	64	0
48235	2.60999999999999988	sterilisation_chemical	65	0
48235	0.000445999999999999999	wastewater	66	0
48235	1.58299999999999996	sodium_hydroxide	67	0
48235	5.94500000000000028	phosphoric_acid	68	0
48235	3.5219999999999998	rawmilk	69	0
48235	0.136099999999999999	heat_mswi	71	0
48235	1.58299999999999996	sodium_hydroxide	72	0
48240	2.60999999999999988	sterilisation_chemical	73	0
48240	0.136099999999999999	heat_mswi	77	0
48240	0.00375299999999999983	water	78	0
48240	0.509800000000000031	electricity_fossil	79	0
48240	3.5219999999999998	rawmilk	80	0
48240	5.94500000000000028	phosphoric_acid	81	0
48240	1.58299999999999996	sodium_hydroxide	82	0
48240	0.000445999999999999999	wastewater	83	0
48239	0.136099999999999999	heat_mswi	85	0
48239	0.00375299999999999983	water	86	0
48239	0.509800000000000031	electricity_fossil	87	0
48239	3.5219999999999998	rawmilk	88	0
48239	5.94500000000000028	phosphoric_acid	89	0
48239	1.58299999999999996	sodium_hydroxide	90	0
48239	0.000445999999999999999	wastewater	91	0
48241	2.60999999999999988	sterilisation_chemical	92	0
48241	0.136099999999999999	heat_mswi	93	0
48241	0.00375299999999999983	water	94	0
48241	0.000445999999999999999	wastewater	97	0
48241	1.58299999999999996	sodium_hydroxide	98	0
48241	5.94500000000000028	phosphoric_acid	99	0
48241	3.5219999999999998	rawmilk	100	0
48235	1800	Industry electricity mix, mainly from coal and nuclear power plants	101	0
48235	1800	Industry electricity mix, mainly from coal and nuclear power plants	102	0
48235	2731	District heat from waste incineration plant	103	0
48235	1800	Industry electricity mix, mainly from coal and nuclear power plants	104	0
48235	1000	Sodium hydroxide for CIP cleaning	105	0
48235	580000	Rawmilk losses	106	0
48235	62600	Waste water with high organic load	107	0
48235	10000000	Rawmilk from cow farms	108	0
48235	1800	Industry electricity mix	109	0
48235	1800	Industry_electricity_mix	110	0
48239	2.60999999999999988	sterilisation_chemical	112	0
48240	0	sterilisation_chemical	113	0
48240	2731	heat_mswi	114	0
48240	62600	water	115	0
48240	10000000	rawmilk	116	0
48240	580000	rawmilk	117	0
48240	1000	sodium_hydroxide	118	0
48240	62600	wastewater	119	0
48240	1000	phosphoric_acid	120	0
48240	1800	electricity_fossil	121	0
48242	0.00260999999999999991	sterilisation_chemical	122	0
48242	10	sample flow	123	0
48242	0.136099999999999999	heat_mswi	124	0
48242	0.00375299999999999983	water	125	0
48242	0.509800000000000031	electricity_fossil	126	0
48242	3.5219999999999998	rawmilk	127	0
48242	5.94500000000000028	phosphoric_acid	128	0
48242	1.58299999999999996	sodium_hydroxide	129	0
48242	0.000445999999999999999	wastewater	130	0
28	3.75300000000000011	water	131	22
48246	10000	raw milk	132	3
48246	5.70000000000000018	water	133	3
48246	5.70000000000000018	acids	134	3
48246	5.70000000000000018	base	135	3
48246	350	milk losses	136	3
48246	288320	electricity	138	3
48246	5428680	energy total	139	3
48246	3.5219999999999998	raw_milk	141	3
48246	1.58299999999999996	caustic_soda	142	3
48246	0.136099999999999999	district_heat	143	8
48246	0.509800000000000031	Electricity	144	8
48246	5.94500000000000028	phosphoric acid	145	3
48246	0.00375299999999999983	water	146	3
48247	5.94500000000000028	phosphoric acid	153	3
48247	2610	helades_pe_15	156	3
48247	136.099999999999994	district_heat	157	8
48247	3.75300000000000011	water	158	3
48247	509.800000000000011	Electricity	159	8
48247	3522	raw_milk	160	3
48247	5945	phosphoric acid	161	3
48247	1583	sodium hydroxide	162	3
48247	0.446000000000000008	wastewater	163	3
28	3522	rawmilk	164	3
48245	777	TEST	166	3
48248	3500	Raw Milk	180	3
48248	3500	Raw Milk Loss	181	3
48248	0.599999999999999978	Waste Water	182	3
48248	0	Acetone liquid	184	3
48248	0	Acids organic	185	3
48248	9040.35000000000036	Acetic acid	186	3
48248	7982	Acetone liquid	187	22
48248	9789456	Acids inorganic	188	3
48248	31564	Acids organic	189	3
28	3476.59999999999991	nutritive_biomass	195	3
48258	3476.59999999999991	nutritivebiomass	196	3
48260	0.00350000000000000007	Nutrition_swine	197	3
48260	0	Malt_cake	198	3
48263	66.0600000000000023	nutritivebiomass	199	3
48257	3480	Nutritive Biomass	205	3
48260	0.00350000000000000007	nutritivebiomass	206	3
48266	200	Milk	208	3
48268	1000	RDF	209	3
48272	0.0381000000000000019	Heat, Hardwood	211	8
48272	0.00809999999999999956	Heat, Natural Gas	212	8
48272	0.0464999999999999997	Heat, Heavy Fuel Oil	213	8
48272	0.0490000000000000019	Heat, Coal Coke	214	3
48272	0.0490000000000000019	Heat, Coal Coke	215	8
48272	0.00020000000000000001	Water	216	3
48272	5.87640000000000029	Steel, chromium	218	3
48272	0.39029999999999998	Steel, unalloyed	219	3
48273	121	Heat Wood	224	8
48273	125	Heat Gas	225	8
48273	404	Heat Oil	226	8
48273	414	Wood	227	3
48273	742	Heat Coal	228	8
48273	0	Water	229	3
48273	10843	Aluminium	230	3
48273	11377	Steel chromium	231	3
48273	3537	Steel unalloyed	232	3
48273	4	Wastewater	233	3
48273	20	Clay	234	3
28	0.92000000000000004	Water ukr	235	3
28	414	wood	236	3
28	124	Heat natural gas	237	8
48270	1.59000000000000008	District heating	245	8
48270	235	Oil heating	246	8
48270	216	Energy mix swiss	247	8
48270	3630	Wastewater	250	20
48270	245	Fresh water	251	20
48266	2610	Halades PE 15	252	3
48266	136.300000000000011	Fernw├ñrme	253	8
48266	510	Strom	254	8
48270	1770	Waste incineration plastic	255	3
48266	5277	Phosphoric Acid	256	3
48266	1619	Sodium Hydroxide	257	3
48266	4710	Raw Milk	258	3
48266	4198	Wasser	259	3
28	4189	water + ARA	260	3
48270	3875	Fresh + waste Water	261	20
48270	485	Transport Euro 5	262	14
48270	354000	R407C	263	3
48270	109	Transport Waste	264	3
48270	459	Recycling of Plastic	268	3
48269	0.00059000000000000003	RDF burning	273	4
48269	0.247999999999999998	MSW transport	275	4
48269	0.0221249999999999988	Electricity	276	9
48269	0.00191000000000000002	Ammonia	278	3
48269	0.140000000000000013	Dust	279	3
48269	0.0389999999999999999	NOx	280	3
48269	1.35000000000000009	Petcoke (1)	282	4
48269	1.35000000000000009	Petcoke (2)	283	4
48269	1.35000000000000009	Petcoke	286	4
28	206100	petcoke	287	7
48269	1.70999999999999989e-05	Biogas	288	7
48299	10	Wasser	291	4
28	0.0100000000000000002	Wasser	292	4
48293	3.95999999999999996	Reaktivfarbstoff	293	4
48299	3.95999999999999996	Farbstoff	294	4
28	1888000	Treber	296	4
28	3.95999999999999996	Reaktivfarbstoff	299	4
1	111	test	300	2
1	123132	asdasdas	301	3
1	1	Lead	302	1
\.


--
-- Data for Name: t_user_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_user_log (id, user_id) FROM stdin;
\.


--
-- Data for Name: t_waste_threatment_cmpny; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_waste_threatment_cmpny (id, name, phone_num_1, fax_num, address, description, email, postal_code, active, city_id, country_id) FROM stdin;
\.


--
-- Data for Name: t_waste_threatment_tecnology; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_waste_threatment_tecnology (id, name, active) FROM stdin;
\.


--
-- Name: clusters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clusters_id_seq', 6, true);


--
-- Name: es_definition_of_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.es_definition_of_type_id_seq', 4, true);


--
-- Name: industrial_zones_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industrial_zones_department_id_seq', 6, false);


--
-- Name: industrial_zones_departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industrial_zones_departments_id_seq', 8, true);


--
-- Name: industrial_zones_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industrial_zones_employee_id_seq', 7, true);


--
-- Name: industrial_zones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industrial_zones_id_seq', 10, true);


--
-- Name: pk_all_company_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_all_company_id_sequence', 3073, true);


--
-- Name: pk_all_company_point_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_all_company_point_id_sequence', 6389, true);


--
-- Name: pk_company_arus_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_arus_sequence', 1, false);


--
-- Name: pk_company_energy_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_energy_sequence', 1, false);


--
-- Name: pk_company_isim_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_isim_sequence', 1, false);


--
-- Name: pk_company_kaucuk_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_kaucuk_sequence', 1, false);


--
-- Name: pk_company_medical_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_medical_sequence', 1, false);


--
-- Name: pk_company_savunma_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_savunma_sequence', 1, false);


--
-- Name: pk_company_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_company_sequence', 16, true);


--
-- Name: pk_gis_is_predefined_project; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_gis_is_predefined_project', 1976, true);


--
-- Name: pk_gis_is_predefined_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_gis_is_predefined_sequence', 15866298, true);


--
-- Name: pk_gis_proje_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pk_gis_proje_id_sequence', 24, true);


--
-- Name: r_report_attributes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.r_report_attributes_id_seq', 23, true);


--
-- Name: r_report_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.r_report_types_id_seq', 9, true);


--
-- Name: r_report_used_attributes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.r_report_used_attributes_id_seq', 1125, true);


--
-- Name: r_report_used_configurations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.r_report_used_configurations_id_seq', 62, true);


--
-- Name: t_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_activity_id_seq', 5, true);


--
-- Name: t_certificates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_certificates_id_seq', 19, true);


--
-- Name: t_cities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cities_id_seq', 81, true);


--
-- Name: t_clstr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_clstr_id_seq', 9, true);


--
-- Name: t_cmpnnt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpnnt_id_seq', 112, true);


--
-- Name: t_cmpnt_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpnt_type_id_seq', 1, false);


--
-- Name: t_cmpny_certificates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_certificates_id_seq', 1, false);


--
-- Name: t_cmpny_clstr_cmpny_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_clstr_cmpny_id_seq', 32, true);


--
-- Name: t_cmpny_eqpmnt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_eqpmnt_id_seq', 74, true);


--
-- Name: t_cmpny_flow_cmpnnt_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_flow_cmpnnt_location_id_seq', 1, false);


--
-- Name: t_cmpny_flow_cmpnnt_waste_threat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_flow_cmpnnt_waste_threat_id_seq', 1, false);


--
-- Name: t_cmpny_flow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_flow_id_seq', 1054, true);


--
-- Name: t_cmpny_flow_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_flow_location_id_seq', 1, false);


--
-- Name: t_cmpny_grp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_grp_id_seq', 1, false);


--
-- Name: t_cmpny_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_id_seq', 3500, true);


--
-- Name: t_cmpny_prcss_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_prcss_id_seq', 446, true);


--
-- Name: t_cmpny_production_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_production_details_id_seq', 1, false);


--
-- Name: t_cmpny_prsnl_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_prsnl_details_id_seq', 1, false);


--
-- Name: t_cmpny_prsnl_key_column_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_prsnl_key_column_seq', 3626, true);


--
-- Name: t_cmpny_sector_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cmpny_sector_id_seq', 1, false);


--
-- Name: t_costbenefit_temp_pkey_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_costbenefit_temp_pkey_seq', 178, true);


--
-- Name: t_country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_country_id_seq', 239, true);


--
-- Name: t_cp_allocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cp_allocation_id_seq', 562, true);


--
-- Name: t_cp_company_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cp_company_project_id_seq', 484, true);


--
-- Name: t_cp_is_candidate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cp_is_candidate_id_seq', 58, true);


--
-- Name: t_cp_scoping_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_cp_scoping_files_id_seq', 29, true);


--
-- Name: t_district_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_district_id_seq', 958, true);


--
-- Name: t_doc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_doc_id_seq', 1, false);


--
-- Name: t_ecotracking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_ecotracking_id_seq', 27, true);


--
-- Name: t_eqpmnt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_eqpmnt_id_seq', 7, true);


--
-- Name: t_eqpmnt_type_attrbt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_eqpmnt_type_attrbt_id_seq', 624, true);


--
-- Name: t_eqpmnt_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_eqpmnt_type_id_seq', 49, true);


--
-- Name: t_flow_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_category_id_seq', 1, false);


--
-- Name: t_flow_family_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_family_id_seq', 26, true);


--
-- Name: t_flow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_id_seq', 354, true);


--
-- Name: t_flow_log_flow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_log_flow_id_seq', 1, false);


--
-- Name: t_flow_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_log_id_seq', 937, true);


--
-- Name: t_flow_total_per_cmpny_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_total_per_cmpny_id_seq', 1, false);


--
-- Name: t_flow_total_per_cmpny_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_total_per_cmpny_id_seq1', 109, true);


--
-- Name: t_flow_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_flow_type_id_seq', 2, true);


--
-- Name: t_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_group_id_seq', 1, false);


--
-- Name: t_infrastructure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_infrastructure_id_seq', 1, false);


--
-- Name: t_is_prj_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_is_prj_details_id_seq', 417, true);


--
-- Name: t_is_prj_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_is_prj_history_id_seq', 1, false);


--
-- Name: t_is_prj_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_is_prj_id_seq', 260, true);


--
-- Name: t_is_prj_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_is_prj_status_id_seq', 5, true);


--
-- Name: t_log_operation_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_log_operation_type_id_seq', 3, true);


--
-- Name: t_nace_code_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_nace_code_id_seq', 2186, true);


--
-- Name: t_nace_code_rev2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_nace_code_rev2_id_seq', 615, true);


--
-- Name: t_org_ind_reg_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_org_ind_reg_id_seq', 3, true);


--
-- Name: t_prcss_family_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_prcss_family_id_seq', 27, true);


--
-- Name: t_prcss_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_prcss_id_seq', 488, true);


--
-- Name: t_prdct_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_prdct_id_seq', 77, true);


--
-- Name: t_prj_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_prj_id_seq', 42114, true);


--
-- Name: t_prj_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_prj_status_id_seq', 5, true);


--
-- Name: t_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_role_id_seq', 5, true);


--
-- Name: t_sector_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_sector_activity_id_seq', 1, false);


--
-- Name: t_sector_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_sector_id_seq', 1, false);


--
-- Name: t_state_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_state_id_seq', 1, false);


--
-- Name: t_synergy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_synergy_id_seq', 6, true);


--
-- Name: t_transport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_transport_id_seq', 1, false);


--
-- Name: t_transportation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_transportation_id_seq', 1, false);


--
-- Name: t_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_unit_id_seq', 49, true);


--
-- Name: t_unit_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_unit_type_id_seq', 3, true);


--
-- Name: t_user_ep_values_primary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_user_ep_values_primary_id_seq', 302, true);


--
-- Name: t_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_user_id_seq', 48305, true);


--
-- Name: t_user_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_user_log_id_seq', 1, false);


--
-- Name: t_waste_threatment_cmpny_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_waste_threatment_cmpny_id_seq', 1, false);


--
-- Name: t_waste_threatment_tecnology_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.t_waste_threatment_tecnology_id_seq', 1, false);


--
-- Name: world1_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.world1_id_seq', 245, false);


--
-- Name: industrial_zones_clusters clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industrial_zones_clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: industrial_zones_employee industrial_zones_employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industrial_zones_employee
    ADD CONSTRAINT industrial_zones_employee_pkey PRIMARY KEY (id);


--
-- Name: industrial_zones industrial_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industrial_zones
    ADD CONSTRAINT industrial_zones_pkey PRIMARY KEY (id);


--
-- Name: r_report_types r_report_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.r_report_types
    ADD CONSTRAINT r_report_types_pkey PRIMARY KEY (id);


--
-- Name: t_activity t_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_activity
    ADD CONSTRAINT t_activity_pkey PRIMARY KEY (id);


--
-- Name: t_certificates t_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_certificates
    ADD CONSTRAINT t_certificates_pkey PRIMARY KEY (id);


--
-- Name: t_cities t_cities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cities
    ADD CONSTRAINT t_cities_pkey PRIMARY KEY (id);


--
-- Name: t_clstr t_clstr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_clstr
    ADD CONSTRAINT t_clstr_pkey PRIMARY KEY (id);


--
-- Name: t_cmpnnt t_cmpnnt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpnnt
    ADD CONSTRAINT t_cmpnnt_pkey PRIMARY KEY (id);


--
-- Name: t_cmpnt_type t_cmpnt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpnt_type
    ADD CONSTRAINT t_cmpnt_type_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_certificates t_cmpny_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_certificates
    ADD CONSTRAINT t_cmpny_certificates_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_clstr t_cmpny_clstr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_clstr
    ADD CONSTRAINT t_cmpny_clstr_pkey PRIMARY KEY (cmpny_id, clstr_id);


--
-- Name: t_cmpny_eqpmnt t_cmpny_eqpmnt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_eqpmnt
    ADD CONSTRAINT t_cmpny_eqpmnt_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_flow_cmpnnt t_cmpny_flow_cmpnnt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt
    ADD CONSTRAINT t_cmpny_flow_cmpnnt_pkey PRIMARY KEY (cmpny_flow_id, cmpnnt_id);


--
-- Name: t_cmpny_flow_location t_cmpny_flow_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_location
    ADD CONSTRAINT t_cmpny_flow_location_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_flow t_cmpny_flow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow
    ADD CONSTRAINT t_cmpny_flow_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_flow_prcss t_cmpny_flow_prcss_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_prcss
    ADD CONSTRAINT t_cmpny_flow_prcss_pkey PRIMARY KEY (cmpny_flow_id, cmpny_prcss_id);


--
-- Name: t_cmpny_grp t_cmpny_grp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_grp
    ADD CONSTRAINT t_cmpny_grp_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_nace_code t_cmpny_nace_code_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_nace_code
    ADD CONSTRAINT t_cmpny_nace_code_pkey PRIMARY KEY (cmpny_id, nace_code_id);


--
-- Name: t_cmpny_org_ind_reg t_cmpny_org_ind_reg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_org_ind_reg
    ADD CONSTRAINT t_cmpny_org_ind_reg_pkey PRIMARY KEY (org_ind_reg_id, cmpny_id);


--
-- Name: t_cmpny t_cmpny_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny
    ADD CONSTRAINT t_cmpny_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_prcss_eqpmnt_type t_cmpny_prcss_eqpmnt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prcss_eqpmnt_type
    ADD CONSTRAINT t_cmpny_prcss_eqpmnt_type_pkey PRIMARY KEY (cmpny_eqpmnt_type_id, cmpny_prcss_id);


--
-- Name: t_cmpny_prcss t_cmpny_prcss_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prcss
    ADD CONSTRAINT t_cmpny_prcss_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_production_details t_cmpny_production_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_production_details
    ADD CONSTRAINT t_cmpny_production_details_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_prsnl_details t_cmpny_prsnl_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prsnl_details
    ADD CONSTRAINT t_cmpny_prsnl_details_pkey PRIMARY KEY (id);


--
-- Name: t_cmpny_prsnl t_cmpny_prsnl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prsnl
    ADD CONSTRAINT t_cmpny_prsnl_pkey PRIMARY KEY (key_column);


--
-- Name: t_cmpny_sector t_cmpny_sector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_sector
    ADD CONSTRAINT t_cmpny_sector_pkey PRIMARY KEY (id);


--
-- Name: t_cnsltnt t_cnsltnt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cnsltnt
    ADD CONSTRAINT t_cnsltnt_pkey PRIMARY KEY (user_id);


--
-- Name: t_costbenefit_temp t_costbenefit_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_costbenefit_temp
    ADD CONSTRAINT t_costbenefit_temp_pkey PRIMARY KEY (pkey);


--
-- Name: t_country t_country_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_country
    ADD CONSTRAINT t_country_pkey PRIMARY KEY (id);


--
-- Name: t_cp_allocation t_cp_allocation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_allocation
    ADD CONSTRAINT t_cp_allocation_pkey PRIMARY KEY (id);


--
-- Name: t_cp_company_project t_cp_company_project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_company_project
    ADD CONSTRAINT t_cp_company_project_pkey PRIMARY KEY (id);


--
-- Name: t_cp_is_candidate t_cp_is_candidate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_is_candidate
    ADD CONSTRAINT t_cp_is_candidate_pkey PRIMARY KEY (id);


--
-- Name: t_cp_scoping_files t_cp_scoping_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_scoping_files
    ADD CONSTRAINT t_cp_scoping_files_pkey PRIMARY KEY (id);


--
-- Name: t_district t_district_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_district
    ADD CONSTRAINT t_district_pkey PRIMARY KEY (id);


--
-- Name: t_doc t_doc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_doc
    ADD CONSTRAINT t_doc_pkey PRIMARY KEY (id);


--
-- Name: t_ecotracking t_ecotracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_ecotracking
    ADD CONSTRAINT t_ecotracking_pkey PRIMARY KEY (id);


--
-- Name: t_eqpmnt t_eqpmnt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt
    ADD CONSTRAINT t_eqpmnt_pkey PRIMARY KEY (id);


--
-- Name: t_eqpmnt_type_attrbt t_eqpmnt_type_attrbt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt_type_attrbt
    ADD CONSTRAINT t_eqpmnt_type_attrbt_pkey PRIMARY KEY (id);


--
-- Name: t_eqpmnt_type t_eqpmnt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt_type
    ADD CONSTRAINT t_eqpmnt_type_pkey PRIMARY KEY (id);


--
-- Name: t_flow_category t_flow_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_category
    ADD CONSTRAINT t_flow_category_pkey PRIMARY KEY (id);


--
-- Name: t_flow_family t_flow_family_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_family
    ADD CONSTRAINT t_flow_family_pkey PRIMARY KEY (id);


--
-- Name: t_flow_log t_flow_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_log
    ADD CONSTRAINT t_flow_log_pkey PRIMARY KEY (id);


--
-- Name: t_flow t_flow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow
    ADD CONSTRAINT t_flow_pkey PRIMARY KEY (id);


--
-- Name: t_flow_type t_flow_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_flow_type
    ADD CONSTRAINT t_flow_type_pkey PRIMARY KEY (id);


--
-- Name: t_group t_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_group
    ADD CONSTRAINT t_group_pkey PRIMARY KEY (id);


--
-- Name: t_infrastructure t_infrastructure_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_infrastructure
    ADD CONSTRAINT t_infrastructure_pkey PRIMARY KEY (id);


--
-- Name: t_is_prj_details t_is_prj_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj_details
    ADD CONSTRAINT t_is_prj_details_pkey PRIMARY KEY (id);


--
-- Name: t_is_prj_history t_is_prj_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj_history
    ADD CONSTRAINT t_is_prj_history_pkey PRIMARY KEY (id);


--
-- Name: t_is_prj t_is_prj_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj
    ADD CONSTRAINT t_is_prj_pkey PRIMARY KEY (id);


--
-- Name: t_is_prj_status t_is_prj_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_is_prj_status
    ADD CONSTRAINT t_is_prj_status_pkey PRIMARY KEY (id);


--
-- Name: t_log_operation_type t_log_operation_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_log_operation_type
    ADD CONSTRAINT t_log_operation_type_pkey PRIMARY KEY (id);


--
-- Name: t_nace_code t_nace_code_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_nace_code
    ADD CONSTRAINT t_nace_code_pkey PRIMARY KEY (id);


--
-- Name: t_nace_code_rev2 t_nace_code_rev2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_nace_code_rev2
    ADD CONSTRAINT t_nace_code_rev2_pkey PRIMARY KEY (id);


--
-- Name: t_org_ind_reg t_org_ind_reg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_org_ind_reg
    ADD CONSTRAINT t_org_ind_reg_pkey PRIMARY KEY (id);


--
-- Name: t_prcss_family t_prcss_family_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prcss_family
    ADD CONSTRAINT t_prcss_family_pkey PRIMARY KEY (id);


--
-- Name: t_prcss t_prcss_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prcss
    ADD CONSTRAINT t_prcss_pkey PRIMARY KEY (id);


--
-- Name: t_prdct t_prdct_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prdct
    ADD CONSTRAINT t_prdct_pkey PRIMARY KEY (id);


--
-- Name: t_prj_acss_cmpny t_prj_acss_cmpny_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_acss_cmpny
    ADD CONSTRAINT t_prj_acss_cmpny_pkey PRIMARY KEY (cmpny_id, prj_id);


--
-- Name: t_prj_acss_user t_prj_acss_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_acss_user
    ADD CONSTRAINT t_prj_acss_user_pkey PRIMARY KEY (user_id, prj_id);


--
-- Name: t_prj_cmpny t_prj_cmpny_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cmpny
    ADD CONSTRAINT t_prj_cmpny_pkey PRIMARY KEY (prj_id, cmpny_id);


--
-- Name: t_prj_cnsltnt t_prj_cnsltnt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cnsltnt
    ADD CONSTRAINT t_prj_cnsltnt_pkey PRIMARY KEY (prj_id, cnsltnt_id);


--
-- Name: t_prj_cntct_prsnl t_prj_cntct_prsnl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cntct_prsnl
    ADD CONSTRAINT t_prj_cntct_prsnl_pkey PRIMARY KEY (prj_id, usr_id);


--
-- Name: t_prj_doc t_prj_doc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_doc
    ADD CONSTRAINT t_prj_doc_pkey PRIMARY KEY (doc_id, prj_id);


--
-- Name: t_prj t_prj_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj
    ADD CONSTRAINT t_prj_pkey PRIMARY KEY (id);


--
-- Name: t_prj_status t_prj_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_status
    ADD CONSTRAINT t_prj_status_pkey PRIMARY KEY (id);


--
-- Name: t_role t_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_role
    ADD CONSTRAINT t_role_pkey PRIMARY KEY (id);


--
-- Name: t_sector_activity t_sector_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_sector_activity
    ADD CONSTRAINT t_sector_activity_pkey PRIMARY KEY (id);


--
-- Name: t_sector t_sector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_sector
    ADD CONSTRAINT t_sector_pkey PRIMARY KEY (id);


--
-- Name: t_state t_state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_state
    ADD CONSTRAINT t_state_pkey PRIMARY KEY (id);


--
-- Name: t_synergy t_synergy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_synergy
    ADD CONSTRAINT t_synergy_pkey PRIMARY KEY (id);


--
-- Name: t_transport t_transport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_transport
    ADD CONSTRAINT t_transport_pkey PRIMARY KEY (id);


--
-- Name: t_transportation t_transportation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_transportation
    ADD CONSTRAINT t_transportation_pkey PRIMARY KEY (id);


--
-- Name: t_unit t_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_unit
    ADD CONSTRAINT t_unit_pkey PRIMARY KEY (id);


--
-- Name: t_unit_type t_unit_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_unit_type
    ADD CONSTRAINT t_unit_type_pkey PRIMARY KEY (id);


--
-- Name: t_user_ep_values t_user_ep_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user_ep_values
    ADD CONSTRAINT t_user_ep_values_pkey PRIMARY KEY (primary_id);


--
-- Name: t_user_log t_user_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user_log
    ADD CONSTRAINT t_user_log_pkey PRIMARY KEY (id);


--
-- Name: t_user t_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user
    ADD CONSTRAINT t_user_pkey PRIMARY KEY (id);


--
-- Name: t_waste_threatment_cmpny t_waste_threatment_cmpny_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_waste_threatment_cmpny
    ADD CONSTRAINT t_waste_threatment_cmpny_pkey PRIMARY KEY (id);


--
-- Name: acetoin_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX acetoin_index ON public.t_flow_total_per_cmpny USING btree ((((("Acetoin" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: acetone_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX acetone_index ON public.t_flow_total_per_cmpny USING btree ((((("Acetone" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: additives_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX additives_index ON public.t_flow_total_per_cmpny USING btree ((((("Additives" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: aliminium_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aliminium_index ON public.t_flow_total_per_cmpny USING btree ((((("Aliminium" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: aliuminium_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aliuminium_index ON public.t_flow_total_per_cmpny USING btree (((((aliuminium -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: aluminium_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX aluminium_index ON public.t_flow_total_per_cmpny USING btree (((((aluminium -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: brass_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX brass_index ON public.t_flow_total_per_cmpny USING btree ((((("Brass" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: b├╝y├╝k_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "b├╝y├╝k_index" ON public.t_flow_total_per_cmpny USING btree ((((("b├╝y├╝k" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: cellulose_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cellulose_index ON public.t_flow_total_per_cmpny USING btree ((((("Cellulose" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: cement_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cement_index ON public.t_flow_total_per_cmpny USING btree ((((("Cement" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: cleaner_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cleaner_index ON public.t_flow_total_per_cmpny USING btree (((((cleaner -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: color_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX color_index ON public.t_flow_total_per_cmpny USING btree ((((("Color" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: concrete_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX concrete_index ON public.t_flow_total_per_cmpny USING btree (((((concrete -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: copper_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX copper_index ON public.t_flow_total_per_cmpny USING btree ((((("Copper" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: csteel_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX csteel_index ON public.t_flow_total_per_cmpny USING btree (((((csteel -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: cuttingfluid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cuttingfluid_index ON public.t_flow_total_per_cmpny USING btree (((((cuttingfluid -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: cuttingoil_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cuttingoil_index ON public.t_flow_total_per_cmpny USING btree (((((cuttingoil -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: cuttingtools_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cuttingtools_index ON public.t_flow_total_per_cmpny USING btree (((((cuttingtools -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: deneme2_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deneme2_index ON public.t_flow_total_per_cmpny USING btree ((((("Deneme2" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: deneme_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deneme_index ON public.t_flow_total_per_cmpny USING btree ((((("Deneme" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: dust_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dust_index ON public.t_flow_total_per_cmpny USING btree ((((("Dust" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: electricity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX electricity_index ON public.t_flow_total_per_cmpny USING btree ((((("Electricity" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: emissiontoair_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX emissiontoair_index ON public.t_flow_total_per_cmpny USING btree ((((("EmissionToAir" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: ethanol_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ethanol_index ON public.t_flow_total_per_cmpny USING btree ((((("Ethanol" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: fki_T_CMPNY_T_CMPNNT_ID; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_T_CMPNY_T_CMPNNT_ID" ON public.t_cmpnnt USING btree (cmpny_id);


--
-- Name: flow1compg_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow1compg_index ON public.t_flow_total_per_cmpny USING btree ((((("flow1compG" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow1compi_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow1compi_index ON public.t_flow_total_per_cmpny USING btree ((((("flow1compI" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow2compg_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow2compg_index ON public.t_flow_total_per_cmpny USING btree ((((("flow2compG" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow2compi_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow2compi_index ON public.t_flow_total_per_cmpny USING btree ((((("flow2compI" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow3compg_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow3compg_index ON public.t_flow_total_per_cmpny USING btree ((((("flow3compG" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow3compi_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow3compi_index ON public.t_flow_total_per_cmpny USING btree ((((("flow3compI" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow4compg_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow4compg_index ON public.t_flow_total_per_cmpny USING btree ((((("flow4compG" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: flow4compi_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flow4compi_index ON public.t_flow_total_per_cmpny USING btree ((((("flow4compI" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: fuel_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fuel_index ON public.t_flow_total_per_cmpny USING btree (((((fuel -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: heat_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX heat_index ON public.t_flow_total_per_cmpny USING btree ((((("Heat" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: idx_industrial_zone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_industrial_zone ON public.t_cmpny USING btree (id);


--
-- Name: ketone_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ketone_index ON public.t_flow_total_per_cmpny USING btree ((((("Ketone" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: ldpe_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ldpe_index ON public.t_flow_total_per_cmpny USING btree (((((ldpe -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: municipalwaste_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX municipalwaste_index ON public.t_flow_total_per_cmpny USING btree ((((("Municipalwaste" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: natural_gas_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX natural_gas_index ON public.t_flow_total_per_cmpny USING btree ((((("Natural_gas" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: newspapers_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX newspapers_index ON public.t_flow_total_per_cmpny USING btree ((((("Newspapers" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: nuts_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX nuts_index ON public.t_flow_total_per_cmpny USING btree (((((nuts -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: packagingwaste_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX packagingwaste_index ON public.t_flow_total_per_cmpny USING btree (((((packagingwaste -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: paper_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX paper_index ON public.t_flow_total_per_cmpny USING btree ((((("Paper" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: pe_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pe_index ON public.t_flow_total_per_cmpny USING btree ((((("PE" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: peroxide_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX peroxide_index ON public.t_flow_total_per_cmpny USING btree ((((("Peroxide" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: plastic_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX plastic_index ON public.t_flow_total_per_cmpny USING btree (((((plastic -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: polysthyrene_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX polysthyrene_index ON public.t_flow_total_per_cmpny USING btree ((((("Polysthyrene" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: recoveredpaper_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX recoveredpaper_index ON public.t_flow_total_per_cmpny USING btree ((((("RecoveredPaper" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: residues_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX residues_index ON public.t_flow_total_per_cmpny USING btree ((((("Residues" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: solvents_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX solvents_index ON public.t_flow_total_per_cmpny USING btree ((((("Solvents" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: steel_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX steel_index ON public.t_flow_total_per_cmpny USING btree (((((steel -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: t_clstr_org_ind_reg_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_clstr_org_ind_reg_id ON public.t_clstr USING btree (org_ind_reg_id);


--
-- Name: t_cmpny_certificates_certificate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_certificates_certificate_id ON public.t_cmpny_certificates USING btree (certificate_id);


--
-- Name: t_cmpny_certificates_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_certificates_cmpny_id ON public.t_cmpny_certificates USING btree (cmpny_id);


--
-- Name: t_cmpny_clstr_clstr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_clstr_clstr_id ON public.t_cmpny_clstr USING btree (clstr_id);


--
-- Name: t_cmpny_eqpmnt_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_eqpmnt_cmpny_id ON public.t_cmpny_eqpmnt USING btree (cmpny_id);


--
-- Name: t_cmpny_eqpmnt_eqpmnt_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_eqpmnt_eqpmnt_id ON public.t_cmpny_eqpmnt USING btree (eqpmnt_id);


--
-- Name: t_cmpny_eqpmnt_eqpmnt_type_attrbt_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_eqpmnt_eqpmnt_type_attrbt_id ON public.t_cmpny_eqpmnt USING btree (eqpmnt_type_attrbt_id);


--
-- Name: t_cmpny_eqpmnt_eqpmnt_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_eqpmnt_eqpmnt_type_id ON public.t_cmpny_eqpmnt USING btree (eqpmnt_type_id);


--
-- Name: t_cmpny_flow_cmpnnt_cmpnnt_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_cmpnnt_cmpnnt_id ON public.t_cmpny_flow_cmpnnt USING btree (cmpnnt_id);


--
-- Name: t_cmpny_flow_cmpnnt_cmpny_flow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_cmpnnt_cmpny_flow_id ON public.t_cmpny_flow_cmpnnt USING btree (cmpny_flow_id);


--
-- Name: t_cmpny_flow_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_cmpny_id ON public.t_cmpny_flow USING btree (cmpny_id);


--
-- Name: t_cmpny_flow_flow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_flow_id ON public.t_cmpny_flow USING btree (flow_id);


--
-- Name: t_cmpny_flow_flow_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_flow_type_id ON public.t_cmpny_flow USING btree (flow_type_id);


--
-- Name: t_cmpny_flow_prcss_cmpny_flow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_prcss_cmpny_flow_id ON public.t_cmpny_flow_prcss USING btree (cmpny_flow_id);


--
-- Name: t_cmpny_flow_prcss_cmpny_prcss_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_flow_prcss_cmpny_prcss_id ON public.t_cmpny_flow_prcss USING btree (cmpny_prcss_id);


--
-- Name: t_cmpny_nace_code_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_nace_code_cmpny_id ON public.t_cmpny_nace_code USING btree (cmpny_id);


--
-- Name: t_cmpny_nace_code_nace_code_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_nace_code_nace_code_id ON public.t_cmpny_nace_code USING btree (nace_code_id);


--
-- Name: t_cmpny_org_ind_reg_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_org_ind_reg_cmpny_id ON public.t_cmpny_org_ind_reg USING btree (cmpny_id);


--
-- Name: t_cmpny_org_ind_reg_org_ind_reg_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_org_ind_reg_org_ind_reg_id ON public.t_cmpny_org_ind_reg USING btree (org_ind_reg_id);


--
-- Name: t_cmpny_prcss_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_prcss_cmpny_id ON public.t_cmpny_prcss USING btree (cmpny_id);


--
-- Name: t_cmpny_prcss_eqpmnt_type_cmpny_eqpmnt_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_prcss_eqpmnt_type_cmpny_eqpmnt_type_id ON public.t_cmpny_prcss_eqpmnt_type USING btree (cmpny_eqpmnt_type_id);


--
-- Name: t_cmpny_prcss_eqpmnt_type_cmpny_prcss_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_prcss_eqpmnt_type_cmpny_prcss_id ON public.t_cmpny_prcss_eqpmnt_type USING btree (cmpny_prcss_id);


--
-- Name: t_cmpny_prcss_prcss_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_prcss_prcss_id ON public.t_cmpny_prcss USING btree (prcss_id);


--
-- Name: t_cmpny_prsnl_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_prsnl_cmpny_id ON public.t_cmpny_prsnl USING btree (cmpny_id);


--
-- Name: t_cmpny_prsnl_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_prsnl_user_id ON public.t_cmpny_prsnl USING btree (user_id);


--
-- Name: t_cmpny_sector_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_sector_cmpny_id ON public.t_cmpny_sector USING btree (cmpny_id);


--
-- Name: t_cmpny_sector_sector_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_cmpny_sector_sector_id ON public.t_cmpny_sector USING btree (sector_id);


--
-- Name: t_eqpmnt_type_attrbt_eqpmnt_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_eqpmnt_type_attrbt_eqpmnt_type_id ON public.t_eqpmnt_type_attrbt USING btree (eqpmnt_type_id);


--
-- Name: t_prdct_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prdct_cmpny_id ON public.t_prdct USING btree (cmpny_id);


--
-- Name: t_prj_acss_cmpny_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_acss_cmpny_cmpny_id ON public.t_prj_acss_cmpny USING btree (cmpny_id);


--
-- Name: t_prj_acss_cmpny_prj_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_acss_cmpny_prj_id ON public.t_prj_acss_cmpny USING btree (prj_id);


--
-- Name: t_prj_acss_user_prj_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_acss_user_prj_id ON public.t_prj_acss_user USING btree (prj_id);


--
-- Name: t_prj_acss_user_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_acss_user_user_id ON public.t_prj_acss_user USING btree (user_id);


--
-- Name: t_prj_cmpny_cmpny_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_cmpny_cmpny_id ON public.t_prj_cmpny USING btree (cmpny_id);


--
-- Name: t_prj_cmpny_prj_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_cmpny_prj_id ON public.t_prj_cmpny USING btree (prj_id);


--
-- Name: t_prj_cnsltnt_cnsltnt_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_cnsltnt_cnsltnt_id ON public.t_prj_cnsltnt USING btree (cnsltnt_id);


--
-- Name: t_prj_cnsltnt_prj_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_cnsltnt_prj_id ON public.t_prj_cnsltnt USING btree (prj_id);


--
-- Name: t_prj_cntct_prsnl_usr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_cntct_prsnl_usr_id ON public.t_prj_cntct_prsnl USING btree (usr_id);


--
-- Name: t_prj_doc_doc_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_doc_doc_id ON public.t_prj_doc USING btree (doc_id);


--
-- Name: t_prj_doc_prj_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_doc_prj_id ON public.t_prj_doc USING btree (prj_id);


--
-- Name: t_prj_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_prj_status_id ON public.t_prj USING btree (status_id);


--
-- Name: t_sector_activity_activity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_sector_activity_activity_id ON public.t_sector_activity USING btree (activity_id);


--
-- Name: t_sector_activity_sector_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_sector_activity_sector_id ON public.t_sector_activity USING btree (sector_id);


--
-- Name: t_unit_unit_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_unit_unit_type_id ON public.t_unit USING btree (unit_type_id);


--
-- Name: t_user_log_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_user_log_user_id ON public.t_user_log USING btree (user_id);


--
-- Name: t_user_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX t_user_role_id ON public.t_user USING btree (role_id);


--
-- Name: test12_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX test12_index ON public.t_flow_total_per_cmpny USING btree (((((test12 -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: test22_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX test22_index ON public.t_flow_total_per_cmpny USING btree (((((test22 -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: testttttt_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX testttttt_index ON public.t_flow_total_per_cmpny USING btree (((((testttttt -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: testtun_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX testtun_index ON public.t_flow_total_per_cmpny USING btree (((((testtun -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: titanium_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX titanium_index ON public.t_flow_total_per_cmpny USING btree (((((titanium -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: vesconite_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX vesconite_index ON public.t_flow_total_per_cmpny USING btree (((((vesconite -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: wastepaper_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX wastepaper_index ON public.t_flow_total_per_cmpny USING btree (((((wastepaper -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: wastewater_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX wastewater_index ON public.t_flow_total_per_cmpny USING btree (((((wastewater -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: water_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX water_index ON public.t_flow_total_per_cmpny USING btree ((((("Water" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: wood_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX wood_index ON public.t_flow_total_per_cmpny USING btree (((((wood -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: woodchips_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX woodchips_index ON public.t_flow_total_per_cmpny USING btree ((((("WoodChips" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: woodcips_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX woodcips_index ON public.t_flow_total_per_cmpny USING btree ((((("WoodCips" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: yeniflow_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX yeniflow_index ON public.t_flow_total_per_cmpny USING btree (((((yeniflow -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: zeynel_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX zeynel_index ON public.t_flow_total_per_cmpny USING btree (((((zeynel -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: zinc_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX zinc_index ON public.t_flow_total_per_cmpny USING btree ((((("Zinc" -> 'flow_properties'::text) ->> 'quantity'::text))::numeric(10,2)));


--
-- Name: t_flow t_flow_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE t_flow_insert_rule AS
    ON INSERT TO public.t_flow DO  INSERT INTO public.t_flow_log (flow_id, creation_date, name, name_tr, active, flow_family_id, log_operation_type)
  VALUES (currval('public.t_flow_id_seq'::regclass), now(), COALESCE(new.name, ''::character varying), COALESCE(new.name_tr, ''::character varying), COALESCE((new.active)::integer, 1), COALESCE(new.flow_family_id, 0), ( SELECT t_log_operation_type.id
           FROM public.t_log_operation_type
          WHERE ((t_log_operation_type.operation_type)::text = 'INSERT'::text)));


--
-- Name: t_flow t_flow_update_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE t_flow_update_rule AS
    ON UPDATE TO public.t_flow DO  INSERT INTO public.t_flow_log (flow_id, creation_date, name, name_tr, active, flow_family_id, log_operation_type)
  VALUES (new.id, now(), COALESCE(new.name, ''::character varying), COALESCE(new.name_tr, ''::character varying), COALESCE((new.active)::integer, 1), COALESCE(new.flow_family_id, 0), ( SELECT t_log_operation_type.id
           FROM public.t_log_operation_type
          WHERE ((t_log_operation_type.operation_type)::text = 'UPDATE'::text)));


--
-- Name: t_cmpny_flow trigger_company_flow_change; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_company_flow_change AFTER INSERT OR DELETE OR UPDATE ON public.t_cmpny_flow FOR EACH ROW EXECUTE PROCEDURE public.trigger_company_flow_change();


--
-- Name: t_cmpny_flow trigger_company_flow_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_company_flow_insert AFTER INSERT OR DELETE OR UPDATE ON public.t_cmpny_flow FOR EACH ROW EXECUTE PROCEDURE public.trigger_company_flow_insert_func();


--
-- Name: t_flow trigger_flow_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_flow_insert AFTER INSERT OR DELETE OR UPDATE ON public.t_flow FOR EACH ROW EXECUTE PROCEDURE public.trigger_flow_insert_func();


--
-- Name: t_cmpny_clstr FK_T_CMPNY_CLSTR_T_CLSTR; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_clstr
    ADD CONSTRAINT "FK_T_CMPNY_CLSTR_T_CLSTR" FOREIGN KEY (clstr_id) REFERENCES public.t_clstr(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_clstr FK_T_CMPNY_CLSTR_T_CMPNY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_clstr
    ADD CONSTRAINT "FK_T_CMPNY_CLSTR_T_CMPNY" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_nace_code FK_T_CMPNY_NACE_CODE_T_CMPNY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_nace_code
    ADD CONSTRAINT "FK_T_CMPNY_NACE_CODE_T_CMPNY" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_nace_code FK_T_CMPNY_NACE_CODE_T_NACE_CODE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_nace_code
    ADD CONSTRAINT "FK_T_CMPNY_NACE_CODE_T_NACE_CODE" FOREIGN KEY (nace_code_id) REFERENCES public.t_nace_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_org_ind_reg FK_T_CMPNY_ORG_IND_REG_T_CMPNY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_org_ind_reg
    ADD CONSTRAINT "FK_T_CMPNY_ORG_IND_REG_T_CMPNY" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_org_ind_reg FK_T_CMPNY_ORG_IND_REG_T_ORG_IND_REG; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_org_ind_reg
    ADD CONSTRAINT "FK_T_CMPNY_ORG_IND_REG_T_ORG_IND_REG" FOREIGN KEY (org_ind_reg_id) REFERENCES public.t_org_ind_reg(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_prcss_eqpmnt_type FK_T_CMPNY_PRCSS_EQPMNT_TYPE_T_CMPNY_EQPMNT_TYPE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prcss_eqpmnt_type
    ADD CONSTRAINT "FK_T_CMPNY_PRCSS_EQPMNT_TYPE_T_CMPNY_EQPMNT_TYPE" FOREIGN KEY (cmpny_eqpmnt_type_id) REFERENCES public.t_cmpny_eqpmnt(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_prcss_eqpmnt_type FK_T_CMPNY_PRCSS_EQPMNT_TYPE_T_CMPNY_PRCSS; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prcss_eqpmnt_type
    ADD CONSTRAINT "FK_T_CMPNY_PRCSS_EQPMNT_TYPE_T_CMPNY_PRCSS" FOREIGN KEY (cmpny_prcss_id) REFERENCES public.t_cmpny_prcss(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_prsnl FK_T_CMPNY_PRSNL_T_CMPNY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prsnl
    ADD CONSTRAINT "FK_T_CMPNY_PRSNL_T_CMPNY" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_prsnl FK_T_CMPNY_PRSNL_T_USER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prsnl
    ADD CONSTRAINT "FK_T_CMPNY_PRSNL_T_USER" FOREIGN KEY (user_id) REFERENCES public.t_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cnsltnt FK_T_CNSLTNT_T_USER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cnsltnt
    ADD CONSTRAINT "FK_T_CNSLTNT_T_USER" FOREIGN KEY (user_id) REFERENCES public.t_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_eqpmnt_type_attrbt FK_T_EQPMNT_ATTRBT_T_EQPMNT_TYPE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_eqpmnt_type_attrbt
    ADD CONSTRAINT "FK_T_EQPMNT_ATTRBT_T_EQPMNT_TYPE" FOREIGN KEY (eqpmnt_type_id) REFERENCES public.t_eqpmnt_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow_cmpnnt FK_T_FLOW_CMPNNT_NAME_T_CMPNNT_NAME; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt
    ADD CONSTRAINT "FK_T_FLOW_CMPNNT_NAME_T_CMPNNT_NAME" FOREIGN KEY (cmpnnt_id) REFERENCES public.t_cmpnnt(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow_cmpnnt FK_T_FLOW_CMPNNT_T_FLOW; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_cmpnnt
    ADD CONSTRAINT "FK_T_FLOW_CMPNNT_T_FLOW" FOREIGN KEY (cmpny_flow_id) REFERENCES public.t_cmpny_flow(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow_prcss FK_T_FLOW_PRCSS_T_FLOW; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_prcss
    ADD CONSTRAINT "FK_T_FLOW_PRCSS_T_FLOW" FOREIGN KEY (cmpny_flow_id) REFERENCES public.t_cmpny_flow(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow_prcss FK_T_FLOW_PRCSS_T_PRCSS; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow_prcss
    ADD CONSTRAINT "FK_T_FLOW_PRCSS_T_PRCSS" FOREIGN KEY (cmpny_prcss_id) REFERENCES public.t_cmpny_prcss(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow FK_T_FLOW_T_FLOW_NAME; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow
    ADD CONSTRAINT "FK_T_FLOW_T_FLOW_NAME" FOREIGN KEY (flow_id) REFERENCES public.t_flow(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow FK_T_FLOW_T_FLOW_TYPE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow
    ADD CONSTRAINT "FK_T_FLOW_T_FLOW_TYPE" FOREIGN KEY (flow_type_id) REFERENCES public.t_flow_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_flow FK_T_FLOW_T_UNIT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_flow
    ADD CONSTRAINT "FK_T_FLOW_T_UNIT" FOREIGN KEY (qntty_unit_id) REFERENCES public.t_unit(id);


--
-- Name: t_cmpny_prcss FK_T_PRCSS_T_PRCSS_NAME; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_prcss
    ADD CONSTRAINT "FK_T_PRCSS_T_PRCSS_NAME" FOREIGN KEY (prcss_id) REFERENCES public.t_prcss(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_acss_cmpny FK_T_PRJ_ACSS_CMPNY_T_CMPNY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_acss_cmpny
    ADD CONSTRAINT "FK_T_PRJ_ACSS_CMPNY_T_CMPNY" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_acss_cmpny FK_T_PRJ_ACSS_CMPNY_T_PRJ; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_acss_cmpny
    ADD CONSTRAINT "FK_T_PRJ_ACSS_CMPNY_T_PRJ" FOREIGN KEY (prj_id) REFERENCES public.t_prj(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_acss_user FK_T_PRJ_ACSS_USER_T_PRJ; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_acss_user
    ADD CONSTRAINT "FK_T_PRJ_ACSS_USER_T_PRJ" FOREIGN KEY (prj_id) REFERENCES public.t_prj(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_acss_user FK_T_PRJ_ACSS_USER_T_USER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_acss_user
    ADD CONSTRAINT "FK_T_PRJ_ACSS_USER_T_USER" FOREIGN KEY (user_id) REFERENCES public.t_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_cmpny FK_T_PRJ_CMPNY_T_CMPNY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cmpny
    ADD CONSTRAINT "FK_T_PRJ_CMPNY_T_CMPNY" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_cmpny FK_T_PRJ_CMPNY_T_PRJ; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cmpny
    ADD CONSTRAINT "FK_T_PRJ_CMPNY_T_PRJ" FOREIGN KEY (prj_id) REFERENCES public.t_prj(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_cnsltnt FK_T_PRJ_CNSLTNT_T_CNSLTNT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cnsltnt
    ADD CONSTRAINT "FK_T_PRJ_CNSLTNT_T_CNSLTNT" FOREIGN KEY (cnsltnt_id) REFERENCES public.t_cnsltnt(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_cnsltnt FK_T_PRJ_CNSLTNT_T_PRJ; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cnsltnt
    ADD CONSTRAINT "FK_T_PRJ_CNSLTNT_T_PRJ" FOREIGN KEY (prj_id) REFERENCES public.t_prj(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_cntct_prsnl FK_T_PRJ_CNTCT_PRSNL_T_USER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_cntct_prsnl
    ADD CONSTRAINT "FK_T_PRJ_CNTCT_PRSNL_T_USER" FOREIGN KEY (usr_id) REFERENCES public.t_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_doc FK_T_PRJ_DOC_T_DOC; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_doc
    ADD CONSTRAINT "FK_T_PRJ_DOC_T_DOC" FOREIGN KEY (doc_id) REFERENCES public.t_doc(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj_doc FK_T_PRJ_DOC_T_PRJ; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj_doc
    ADD CONSTRAINT "FK_T_PRJ_DOC_T_PRJ" FOREIGN KEY (prj_id) REFERENCES public.t_prj(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_prj FK_T_PRJ_T_STATUS; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_prj
    ADD CONSTRAINT "FK_T_PRJ_T_STATUS" FOREIGN KEY (status_id) REFERENCES public.t_prj_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_user_log FK_T_USER_LOG_T_USER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user_log
    ADD CONSTRAINT "FK_T_USER_LOG_T_USER" FOREIGN KEY (user_id) REFERENCES public.t_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_user FK_T_USER_T_ROLE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_user
    ADD CONSTRAINT "FK_T_USER_T_ROLE" FOREIGN KEY (role_id) REFERENCES public.t_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_eqpmnt T_CMPNY_EQPMNT_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_eqpmnt
    ADD CONSTRAINT "T_CMPNY_EQPMNT_ibfk_1" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_eqpmnt T_CMPNY_EQPMNT_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_eqpmnt
    ADD CONSTRAINT "T_CMPNY_EQPMNT_ibfk_2" FOREIGN KEY (eqpmnt_id) REFERENCES public.t_eqpmnt(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_eqpmnt T_CMPNY_EQPMNT_ibfk_3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_eqpmnt
    ADD CONSTRAINT "T_CMPNY_EQPMNT_ibfk_3" FOREIGN KEY (eqpmnt_type_id) REFERENCES public.t_eqpmnt_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpny_eqpmnt T_CMPNY_EQPMNT_ibfk_4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_eqpmnt
    ADD CONSTRAINT "T_CMPNY_EQPMNT_ibfk_4" FOREIGN KEY (eqpmnt_type_attrbt_id) REFERENCES public.t_eqpmnt_type_attrbt(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: t_cmpnnt T_CMPNY_T_CMPNNT_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpnnt
    ADD CONSTRAINT "T_CMPNY_T_CMPNNT_ID" FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id);


--
-- Name: t_cp_allocation fk1_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_allocation
    ADD CONSTRAINT fk1_child FOREIGN KEY (prcss_id) REFERENCES public.t_prcss(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_company_project fk1_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_company_project
    ADD CONSTRAINT fk1_child FOREIGN KEY (allocation_id) REFERENCES public.t_cp_allocation(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_is_candidate fk1_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_is_candidate
    ADD CONSTRAINT fk1_child FOREIGN KEY (allocation_id) REFERENCES public.t_cp_allocation(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_scoping_files fk1_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_scoping_files
    ADD CONSTRAINT fk1_child FOREIGN KEY (prjct_id) REFERENCES public.t_prj(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_allocation fk2_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_allocation
    ADD CONSTRAINT fk2_child FOREIGN KEY (flow_id) REFERENCES public.t_flow(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_company_project fk2_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_company_project
    ADD CONSTRAINT fk2_child FOREIGN KEY (prjct_id) REFERENCES public.t_prj(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_scoping_files fk2_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_scoping_files
    ADD CONSTRAINT fk2_child FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_allocation fk3_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_allocation
    ADD CONSTRAINT fk3_child FOREIGN KEY (flow_type_id) REFERENCES public.t_flow_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cp_company_project fk3_child; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cp_company_project
    ADD CONSTRAINT fk3_child FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_clstr t_clstr_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_clstr
    ADD CONSTRAINT t_clstr_ibfk_1 FOREIGN KEY (org_ind_reg_id) REFERENCES public.t_org_ind_reg(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cmpny_certificates t_cmpny_certificates_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_certificates
    ADD CONSTRAINT t_cmpny_certificates_ibfk_1 FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cmpny_certificates t_cmpny_certificates_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_certificates
    ADD CONSTRAINT t_cmpny_certificates_ibfk_2 FOREIGN KEY (certificate_id) REFERENCES public.t_certificates(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cmpny_sector t_cmpny_sector_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_sector
    ADD CONSTRAINT t_cmpny_sector_ibfk_1 FOREIGN KEY (cmpny_id) REFERENCES public.t_cmpny(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_cmpny_sector t_cmpny_sector_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_cmpny_sector
    ADD CONSTRAINT t_cmpny_sector_ibfk_2 FOREIGN KEY (sector_id) REFERENCES public.t_sector(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_sector_activity t_sector_activity_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_sector_activity
    ADD CONSTRAINT t_sector_activity_ibfk_1 FOREIGN KEY (sector_id) REFERENCES public.t_sector(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_sector_activity t_sector_activity_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_sector_activity
    ADD CONSTRAINT t_sector_activity_ibfk_2 FOREIGN KEY (activity_id) REFERENCES public.t_activity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: t_unit t_unit_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_unit
    ADD CONSTRAINT t_unit_ibfk_1 FOREIGN KEY (unit_type_id) REFERENCES public.t_unit_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


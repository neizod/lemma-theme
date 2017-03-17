--- 
layout: post
title: MultipartHttpServletRequest를 이용해 웹 페이지에 input으로 업로드한 파일 데이터 베이스에 넣기
disqus: y
---

# 모임 웹 사이트 개발- MultipartHttpServletRequest를 이용해 웹 페이지에 input으로 업로드한 파일 데이터 베이스에 넣기


### 1. 먼저 MultipartHttpServletRequest를 이용하기 위해 pom.xml에 dependency를 추가해준다.

``` 
<!-- MultipartHttpServletRequest -->
		<dependency>
			<groupId>commons-io</groupId>
			<artifactId>commons-io</artifactId>
			<version>2.0.1</version>
		</dependency>

		<dependency>
			<groupId>commons-fileupload</groupId>
			<artifactId>commons-fileupload</artifactId>
			<version>1.2.2</version>
		</dependency>
```

### 2. root-context에 MultipartResolver 설정을 위해 bean을 추가한다.

``` 
	<!-- MultipartResolver 설정 -->
	<bean id="multipartResolver"
		class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
		<property name="maxUploadSize" value="100000000" />
		<property name="maxInMemorySize" value="100000000" />
	</bean>

```
resolver의 property를 보면 maxUploadSize가 있는 데, value의 단위는 byte이다. 그러므로 10MB까지 업로드가 가능하다.

### 3. JSP에 input 태그를 통해 이미지를 첨부할 수 있도록 한다

`<input type="file" accept="image/*" id="main-image-reg" name="mainImage" class="form-control">`

input tag의 type을 file로 해주고, accept를 'image/*'로 해주었다. 모임 웹 페이지에서 내가 맡은 장소 등록은 이미지만 등록하기 때문에 accept를 이미지로 해주었다.

![Inline-image-2017-01-22 17.04.39.978.png](/files/1868715807776979860)

또한, 위의 화면에서처럼 사용자가 첨부한 이미지를 미리 볼 수 있도록 했는데,
그를 위해서는 html과 스크립트에 아래의 코드를 추가해준다.

`<img id="imagePreview" src="#" class="img-fluid img-thumbnail" alt=" 대표 사진 미리보기 " />`
                                    

``` 
$("#main-image-reg").change(function() {
	readUploadImage(this, 0);
});
                            
function readUploadImage(obj) {
	if (!(window.File && window.FileReader)) {
		alert("미리보기를 지원하지 않는 브라우저 입니다.");
		return;
    }

	if (obj.files && obj.files[0]) {
		if (!(/image/i).test(obj.files[0].type)) {
			alert("이미지 파일만 선택해주세요.");
			return;
		}

		var reader = new FileReader();

		reader.onload = function(e) {
			$('#imagePreview').attr('src', e.target.result);
		}

		reader.readAsDataURL(obj.files[0]);
    }
}
                           
```
reader를 통해 FileReader를 불러온 뒤, reader가 onload일 때, imagePreview에 사진을 추가해준다. 



### 4. form tag에 entype="multipart/form-data"를 추가해준다.
`				<form id="place-registration-form" enctype="multipart/form-data"
					class="form-horizontal" action="/cogather/roomregistration"
					method="post">`

### 5. CommonUtils 클래스를 생성한다.

``` 
public class CommonUtils {
	
	public static String getRandomString() {
		return UUID.randomUUID().toString().replaceAll("-","");
	}
}

```
getRandomString은 32글자의 랜덤한 문자열을 만들어 반환해주는 역할을 한다.

### 6. FileUtils 클래스를 생성한다.

changeToFileInfo() 함수는 multipartFile을 받아 파일의 정보를 포함하는 map을 만들어 반환한다. 위에서 작성한 CommonUtils를 이용해 새로운 파일 이름을 만들어 경로와 함께 path로 추가해준다. 또한, 나머지는 확장자와 원래의 파일 이름이다. 

parsePlaceInsertFileInfo() 함수는 changeToFileInfo로 파일의 정보를 저장한 map을 받은 뒤, 실제 multipart file을 경로를 따라 파일에 저장한다.

``` 
public class FileUtils {
	// 임시 파일 저장
	private static final String filePath = "C:\\dcv\\file\\";

	public Map<String,String> parsePlaceInsertFileInfo(MultipartFile multipartFile) throws Exception {
		String newFilePath = null;

		File file = new File(filePath);
		if (file.exists() == false) {
			file.mkdirs();
		}

		Map<String,String> map = changeToFileInfo(multipartFile);
		
		newFilePath = map.get("path");

		file = new File(newFilePath);
		multipartFile.transferTo(file);
		
		return map;
	}

	private Map<String,String> changeToFileInfo(MultipartFile multipartFile) throws IllegalStateException, IOException {
		String originalFileName = null;
		String originalFileExtension = null;
		String storedFileName = null;

		originalFileName = multipartFile.getOriginalFilename();
		originalFileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
		storedFileName = CommonUtils.getRandomString() + originalFileExtension;
		
		String path = filePath + storedFileName;

		Map<String, String> map = new HashMap<String, String>();
		map.put("name", originalFileName);
		map.put("extension", originalFileExtension);
		map.put("path", path);
		
		return map;
	}

```


### 7. Controller, DAO, Service에 파일을 넣기 위한 코드를 추가한다.

여기서 하나의 파일은 장소의 대표이미지로 사용될 것이기 때문에 경로만을 추가해준다.  먼저, insert를 위한 sql문을 작성해준다. 장소를 추가하기 위한 sql문이기 때문에 중간에 main_img가 파일 경로를 포함하고 있다. useGeneratedKey, keyProperty를 추가해주면, 생성된 id 값을 파라미터로 받은 PlaceDto에 id로 추가해 반환이 가능하다. 

``` 
	<insert id="addPlace" parameterType="com.nhnent.cogather.dto.common.PlaceDto"
		useGeneratedKeys="true" keyProperty="id">
		INSERT INTO place (
			owner_id,
			name,
			main_img,
			location,
			latitude,
			longitude,
			phone,
			start_working_time,
			end_working_time,
			content,
			created_date,
			created_by
		) VALUES (
			#{ownerId},
			#{name},
			#{mainImg},
			#{location},
			#{latitude},
			#{longitude},
			#{phone},
			#{startWorkingTime},
			#{endWorkingTime},
			#{content},
			NOW(),
			1
		);
	</insert>
```

* DAO  
 먼저 AbstratDAO를 만들어준다. sqlSession을 이용한 insert와 update,delete, select를 포함하고 있다. 나머지 DAO에서는 이를 상속받은 뒤, 이미 작성되어있는 함수들을 이용해 퀴리문을 사용한다.

``` 
public abstract class AbstractDAO {
	@Autowired
	private SqlSessionTemplate sqlSession;

	public Object insert(String queryId, Object params) {
		return sqlSession.insert(queryId, params);
	}

	public Object update(String queryId, Object params) {
		return sqlSession.update(queryId, params);
	}

	public Object delete(String queryId, Object params) {
		return sqlSession.delete(queryId, params);
	}

	public Object selectOne(String queryId) {
		return sqlSession.selectOne(queryId);
	}

	public Object selectOne(String queryId, Object params) {
		return sqlSession.selectOne(queryId, params);
	}

	@SuppressWarnings("rawtypes")
	public List selectList(String queryId) {
		return sqlSession.selectList(queryId);
	}

	@SuppressWarnings("rawtypes")
    public List selectList(String queryId, Object params){
        return sqlSession.selectList(queryId,params);
    }
	
}
```

``` 
@Repository("placeRegistrationDaoMyBatis")
public class PlaceRegistrationDaoMyBatis extends AbstractDAO implements PlaceRegistrationDao {
	
	@Override
	public int addPlace(PlaceDto placeDto) {
		insert("placeRegistration.addPlace", placeDto);
		return placeDto.getId();
	}

}
```
AbstractDao에 작성된 insert를 이용해 placeDto를 parameter로 넘겨준다.
삽입한 뒤 생성된 id값이 placeDto에 추가되었기 때문에 그 값을 반환해준다.

* Service
서비스에서는 앞서 작성한 FileUtils를 이용해 file을 저장소에 저장하고 그에 관한 데이터를 가져온다. 또한, 그 경로를 placeDto에 저장해 준 뒤, dao로 넘겨준다.

``` 
@Service("placeRegistrationService")
public class PlaceRegistrationService {

	@Resource(name="placeRegistrationDaoMyBatis")
	private PlaceRegistrationDaoMyBatis _prDao;
	
	private FileUtils _fu;
	

	public int addPlace(Map<String, Object> map) throws Exception {
		this._fu = new FileUtils();
		
		PlaceDto placeDto = (PlaceDto) map.get("placeDto");
		Map<String,String> imageMap = this._fu.parsePlaceInsertFileInfo((MultipartFile)map.get("mainImage"));
		placeDto.setMainImg(imageMap.get("path"));
		placeDto.setOwnerId(1);
		
		return this._prDao.addPlace(placeDto);
	}
}
```

* Controller
컨트롤러는 parameter로 HttpServletRequest를 받은 뒤, 이를 MultipartHttpServletRequest로 형변환해 multiReq에 넣어 주었다. 

multiReq.getFile을 통해 mainImage라는 하나의 파일로 얻어왔다. 

``` 
 // file
 MultipartHttpServletRequest multiReq = (MultipartHttpServletRequest) req;
		

Map<String, Object> map = new HashMap<String, Object>();
map.put("mainImage", multiReq.getFile("mainImage"));
map.put("placeDto", placeDto);
```

만약, multiple attribute를 넣은 여러 개의 파일을 가져오고 싶다면,

* JSP

``` 
<input type="file" accpet="image/*" id="multi-image-reg"
									class="form-control" name="placeImages[]" multiple>
```

위에서처럼 getFile이 아닌, getFiles를 이용하면 된다. getFiles를 하게 되면 추가된 파일들을 List의 형태로 반환해준다.

* Controller
``` 
List<MultipartFile> files = multiReq.getFiles("placeImages[]");
```

나머지는 하나의 파일처럼 FileUtils를 이용해 처리해준 뒤, 데이터 베이스에 insert 해주면 된다.



### 참고한 페이지 : 흔한 개발자의 개발 노트 - http://addio3305.tistory.com/83

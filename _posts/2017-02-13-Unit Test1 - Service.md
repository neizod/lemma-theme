--- 
layout: post
title: Unit Test1 - Service
disqus: y
---

# Unit Test1 - Service

TDD 교육을 듣기 전까지 인터넷도 검색하고 책도 봤지만, Controller나 DAO 테스트에 비해 Service 테스트에 관련된 정보는 잘 나오지 않았다.
그래서 토비의 스프링 책을 참고하면서 DB에 Service를 이용해 데이터를 넣고 그 데이터를 다시 꺼내와 Service에서 의도한 대로 들어갔는지 확인하는 형식으로 코드를 짰다. 하지만, 이렇게 테스트를 만들다 보니 과연 이 테스트가 Service를 테스트하기 위한 코드인지 DAO를 테스트하기 위한 코드인지 모호해져서 TDD 교육에서 각 Layer별로 테스트하는 코드를 배울 수 있어서 좋았다.


## Service의 addCategoryRelList 

``` 
	public void addCategoryRelList(String categoryList, int placeId, int userId) {
		StringTokenizer st = new StringTokenizer(categoryList, "$");

		while (st.hasMoreTokens()) {
			String categoryId = st.nextToken();
			CategoryRelDto categoryRelDto = new CategoryRelDto();
			categoryRelDto.setCategoryId(Integer.parseInt(categoryId));
			categoryRelDto.setParent("PLACE");
			categoryRelDto.setParentId(placeId);
			categoryRelDto.setCreatedBy(userId);

			this.placeRegistrationDao.addCategoryRel(categoryRelDto);
		}

	}
```
addCategoryRelList는 $을 구분자로 가지는 categoryList를 토크나이즈해 CategoryRelDto 객체를 만들어 Dao로 전달한다. 



### 교육 이전의 Test

먼저, 이전에 작성한 PlaceRegistration의 addCategoryRelList 메소드의  테스트 코드를 살펴보면, 


``` 
private List<CategoryRelDto> categoryRelList;
private String categories;
	
@Before
public void setUp() {
	categories = "";
	CategoryRelDto categoryRel1 = new CategoryRelDto();
	categoryRel1.setCategoryId(1);
	categoryRel1.setParent("PLACE");
	categoryRel1.setParentId(1);
	categories += 1+"$";
				
	CategoryRelDto categoryRel2 = new CategoryRelDto();
	categoryRel2.setCategoryId(2);
	categoryRel2.setParent("PLACE");
	categoryRel2.setParentId(1);
	categories += 2+"$";
	
	categoryRelList = new ArrayList<CategoryRelDto>();
	categoryRelList.add(categoryRel1);
	categoryRelList.add(categoryRel2);
}
```

``` 
@Test
public void testAddCategoryRelList() {
	placeRegistrationService.addCategoryRelList(categories, 1, 82);
	Map<String, Object> map = new HashMap<String,Object>();
	map.put("parent", categoryRelList.get(0).getParent());
	map.put("parentId",categoryRelList.get(0).getParentId());

	@SuppressWarnings("unchecked")
	List<CategoryRelDto> relList = placeRegistrationDao.selectList("common.getCategoryRelList", map);
		
	assertThat(relList.size(), is(categoryRelList.size()));
	assertThat(relList.get(0).getParent(), is(categoryRelList.get(0).getParent()));
	assertThat(relList.get(0).getParentId(), is(categoryRelList.get(0).getParentId()));
}

```

테스트를 위해 setUp 메소드에서 먼저 CategoryRelDto에 대한 데이터를 설정하고, 그 데이터를 testAddCategoryRelList()에 넣어준 뒤, placeRegistrationDao로 넣어준 CategoryRel을 불러와서 assertThat으로 하나하나 확인해주었다. 

### 교육 이후의 test

TDD 수업을 들으면서 Service도 Mock 통해 Test해줄 수 있다는 걸 배웠고, 그걸 적용해서 수정해보았다.

``` 
@Test
public void testAddCategoryRelList() {	
	placeRegistrationService.addCategoryRelList("1$2$3$", 1, 82);
	verify(placeRegistrationDao, times(3)).addCategoryRel(anyObject());
}
```
Mock으로 placeRegistrationDao라는 가짜 DAO 객체를 만들어줬다. 그후, "1$2$3" 세 개의 카테고리를 넣어준 뒤, placeRegistrationDao의 addCategoryRel이 3번 불리는지 확인을 통해서 테스트를 해줬다.

Service에서 DB를 이용해 확인한다는 점이 DAO 테스트와 구분을 두기 애매했고, 코드도 복잡해서 보기 어려웠다. Mock으로 Dao를 호출하는 횟수 등을 확인하니 테스트가 더 간편해지고 좀더 Service의 목적에 맞는 테스트라고 생각되어 만족스러웠다.

package org.rapfigueiredo.app;

import org.junit.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class AppApplicationTest {

	@Test
	public void test0() {
		AppApplication.main(new String[]{});
	}

	@Test
	public void test1() {
		try{
			AppApplication.main(null);
		}catch(IllegalArgumentException iae){
		}
	}

	@Test
	public void test2() {
		AppApplication.main(new String[]{"--foo=bar"});
	}

	@Test
	public void test3() {
		AppApplication.main(new String[]{"azsedrfxcvbnmlçjhgfdrtyuiop"});
	}

	@Test
	public void test4() {
		AppApplication.main(new String[]{"azsedrfxcvbnmlçjhgfdrtyuiop","dsadsadsadasdas","1.0","x=y"});
	}

	@Test
	public void test5() {
		try{
			AppApplication.main(new String[]{null});
		}catch(NullPointerException npe){		
		}
	}

}

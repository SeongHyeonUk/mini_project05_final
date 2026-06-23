package com.aivle.bookapp.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

    // 허용 Origin은 환경변수 CORS_ALLOWED_ORIGINS(콤마 구분)로 주입.
    // 미설정 시 로컬 개발 기본값. 운영(AWS)에서는 프론트 도메인/IP를 지정.
    @Value("${app.cors.allowed-origins}")
    private String[] allowedOrigins;

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {

            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                        // allowCredentials(true)와 함께 와일드카드 패턴을 쓰려면
                        // allowedOrigins 대신 allowedOriginPatterns 사용 (예: http://13.124.*.*)
                        .allowedOriginPatterns(allowedOrigins)
                        .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(true);
            }
        };
    }
}

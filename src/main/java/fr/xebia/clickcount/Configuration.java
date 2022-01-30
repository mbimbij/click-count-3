package fr.xebia.clickcount;

import lombok.extern.slf4j.Slf4j;

import javax.inject.Singleton;

@Singleton
@Slf4j
public class Configuration {

    public final String redisHost;
    public final int redisPort;
    public final int redisConnectionTimeout;  //milliseconds

    public Configuration() {
        redisHost = getEnvVarAsString("REDIS_HOST", "redis");
        redisPort = getEnvVarAsInteger("REDIS_PORT", 6379);
        redisConnectionTimeout = getEnvVarAsInteger("REDIS_CONNECTION_TIMEOUT", 2000);
        System.out.println("system.out - redisHost:" + redisHost);
        System.out.println("system.out - redisPort:" + redisPort);
        System.out.println("system.out - redisConnectionTimeout:" + redisConnectionTimeout);
        log.info("redisHost: {}", redisHost);
        log.info("redisPort: {}", redisPort);
        log.info("redisConnectionTimeout: {}", redisConnectionTimeout);
    }

    private String getEnvVarAsString(String envVarName, String defaultValue) {
        String value = System.getenv(envVarName);
        if (value==null) {
            return defaultValue;
        }
        return value;
    }

    private int getEnvVarAsInteger(String envVarName, int defaultValue) {
        try {
            return Integer.parseInt(System.getenv(envVarName));
        } catch (RuntimeException e) {
            return defaultValue;
        }
    }
}

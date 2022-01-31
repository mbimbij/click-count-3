package fr.xebia.clickcount;

import lombok.ToString;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;

import javax.inject.Singleton;

@Singleton
@Slf4j
@ToString
public class Configuration {

    public final String redisHost;
    public final int redisPort;
    public final int redisConnectionTimeoutMillis;
    public final String redisPassword;

    public Configuration(String redisHost, int redisPort, int redisConnectionTimeoutMillis, String redisPassword) {
        this.redisHost = redisHost;
        this.redisPort = redisPort;
        this.redisConnectionTimeoutMillis = redisConnectionTimeoutMillis;
        this.redisPassword = redisPassword;
    }

    public Configuration() {
        redisHost = getEnvVarAsString("REDIS_HOST", "redis");
        redisPort = getEnvVarAsInteger("REDIS_PORT", 6379);
        redisConnectionTimeoutMillis = getEnvVarAsInteger("REDIS_CONNECTION_TIMEOUT", 2000);
        redisPassword = getEnvVarAsString("REDIS_PASSWORD", "");

        // Beware of logging secrets
        log.info("Configuration: {}", this);
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

    @ToString.Include(name = "redisPassword")
    public String maskedPassword() {
        if (StringUtils.isBlank(redisPassword)) {
            return "XXXXXX";
        } else if (redisPassword.length() < 3) {
            return redisPassword.charAt(0) + "XXXXXX";
        }
        return redisPassword.substring(0, 3) + "XXXXXX";
    }
}

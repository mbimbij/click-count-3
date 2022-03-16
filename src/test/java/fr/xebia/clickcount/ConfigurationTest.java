package fr.xebia.clickcount;

import org.junit.jupiter.api.Test;

class ConfigurationTest {
    @Test
    void configurationShouldNotWriteSensitiveInformationWithToString() {
        Configuration configuration = new Configuration("host", 6379, 2000, "somePassword");
        System.out.println(configuration);
    }
}

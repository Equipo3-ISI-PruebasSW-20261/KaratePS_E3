package org.udea.parabank;

import com.intuit.karate.junit5.Karate;

class TestRunner {

    @Karate.Test
    Karate test01_ParabankLogin() {
        return Karate.run("login")
                .relativeTo(getClass())
                .outputCucumberJson(true);
    }

    @Karate.Test
    Karate test02_ParabankTransfer() {
        return Karate.run("TransferFunds")
                .relativeTo(getClass())
                .outputCucumberJson(true);
    }

      @Karate.Test
    Karate test03_ParabankAccount() {
        return Karate.run("account")
                .relativeTo(getClass())
                .outputCucumberJson(true);
    }

}

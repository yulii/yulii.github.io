---
layout: post
title:  "Maven から SAStruts + DBFlute のプロジェクトを新規作成"
date:   2010-07-14 06:16:19 UTC+9
category: engineering
tags: java maven eclipse
---

## DBFlute (SAStruts ベース) プロジェクトの雛形生成

Maven の `archetype:generate` で DBFlute のオプションを指定する。

### DBFlute プロジェクトの生成コマンド

SAStruts の雛形に DBFlute オプションを追加すると、必要な設定を含め雛形が出来る。

```
mvn archetype:generate -DarchetypeRepository=https://www.seasar.org/maven/maven2/ \
    -DarchetypeGroupId=org.seasar.sastruts \
    -DarchetypeArtifactId=sa-struts-archetype -DarchetypeVersion=1.0.4-sp7 \
    -DgroupId=entity.app -DartifactId=entity -Dversion=0.1.0 \
    -Duse-dbflute=true -Ddbflute-version=0.9.6.1 -Ddbflute-plugin-version=0.3.0
```

#### Eclipse プロジェクトに適応させる

プロジェクトのROOT ディレクトリ内で、`eclipse:eclipse` タスクを実行する。

```
mvn eclipse:eclipse
```

m2eclipse プラグインの場合は `eclipse:m2eclipse`


### データベースの設定 (MySQL)

`pom.xml` にデータベースへの接続設定を追加する。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>entity.app</groupId>
  <artifactId>entity</artifactId>
  <version>0.1.0</version>
  <packaging>war</packaging>
  <description/>
  <build>
    <!-- 追加:targetの指定 -->
    <sourceDirectory>src/main/java</sourceDirectory>
    <outputDirectory>target/classes</outputDirectory>
    <!-- 以上 -->
    <finalName>entity</finalName>
    <plugins>

      <!-- 中略 -->

      <!-- Webアプリ用の設定をコメントアウト
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>2.1-beta-1</version>
        <configuration>
          <warSourceExcludes>WEB-INF/classes/**/*.*,WEB-INF/lib/*.jar</warSourceExcludes>
        </configuration>
      </plugin>
      <plugin>
        <artifactId>maven-clean-plugin</artifactId>
        <configuration>
          <filesets>
            <fileset>
              <directory>src/main/webapp/WEB-INF/classes</directory>
            </fileset>
            <fileset>
              <directory>src/main/webapp/WEB-INF/lib</directory>
            </fileset>
          </filesets>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-antrun-plugin</artifactId>
        <version>1.3</version>
        <executions>
          <execution>
            <id>delete-lib-dir</id>
            <phase>initialize</phase>
            <configuration>
              <tasks>
                <delete dir="src/main/webapp/WEB-INF/lib"/>
              </tasks>
            </configuration>
            <goals>
              <goal>run</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-dependency-plugin</artifactId>
        <version>2.0</version>
        <executions>
          <execution>
            <goals>
              <goal>copy-dependencies</goal>
            </goals>
            <configuration>
              <outputDirectory>src/main/webapp/WEB-INF/lib</outputDirectory>
              <excludeScope>provided</excludeScope>
              <overWriteIfNewer>true</overWriteIfNewer>
              <overWriteReleases>true</overWriteReleases>
              <overWriteSnapshots>true</overWriteSnapshots>
            </configuration>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-eclipse-plugin</artifactId>
        <version>2.5.1</version>
        <configuration>
          <buildOutputDirectory>src/main/webapp/WEB-INF/classes</buildOutputDirectory>
          <downloadSources>true</downloadSources>
          <additionalProjectnatures>
            <projectnature>com.sysdeo.eclipse.tomcat.tomcatnature</projectnature>
          </additionalProjectnatures>
        </configuration>
      </plugin>
      -->
      <plugin>
        <groupId>org.seasar.dbflute</groupId>
        <artifactId>maven-dbflute-plugin</artifactId>
        <version>0.3.0</version>
        <configuration>
          <dbfluteVersion>0.9.6.1</dbfluteVersion>
          <!-- 自動生成されるクラスのパッケージ設定 -->
          <rootPackage>entity.app</rootPackage>
          <dbPackage>entity.app.db</dbPackage>
          <schemaName>entity</schemaName>
          <schemaFile>${basedir}/dbflute_entity/schema/project-schema-entity.xml</schemaFile>
      <!-- 追加: MySQL の設定 -->
          <database>mysql</database>
          <databaseDriver>com.mysql.jdbc.Driver</databaseDriver>
          <databaseUrl>jdbc:mysql://localhost/entity?useUnicode=true&amp;amp;characterEncoding=UTF-8</databaseUrl>
          <databaseUser>user</databaseUser>
          <databasePassword>pass</databasePassword>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>sql-maven-plugin</artifactId>
        <executions>
          <execution>
            <id>drop-db</id>
            <phase>process-resources</phase>
            <goals>
              <goal>execute</goal>
            </goals>
            <configuration>
              <url>
                jdbc:mysql://localhost:3306/
              </url>
              <autocommit>true</autocommit>
              <sqlCommand>
                drop database entity
              </sqlCommand>
              <onError>continue</onError>
            </configuration>
          </execution>
          <execution>
            <id>create-db</id>
            <phase>process-resources</phase>
            <goals>
              <goal>execute</goal>
            </goals>
            <configuration>
              <url>
                jdbc:mysql://localhost:3306/
              </url>
              <autocommit>true</autocommit>
              <sqlCommand>
                create database entity
              </sqlCommand>
            </configuration>
          </execution>
          <execution>
            <id>create-schema</id>
            <phase>process-resources</phase>
            <goals>
              <goal>execute</goal>
            </goals>
            <configuration>
              <autocommit>true</autocommit>
              <srcFiles>
                <srcFile>erd/entity.ddl</srcFile>
              </srcFiles>
            </configuration>
          </execution>
        </executions>
        <dependencies>
          <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.0.4</version>
          </dependency>
        </dependencies>
        <configuration>
          <username>user</username>
          <password>pass</password>
          <settingsKeys>sensibleKey</settingsKeys>
          <driver>com.mysql.jdbc.Driver</driver>
          <url>jdbc:mysql://localhost:3306/entity</url>
          <skip>${maven.test.skip}</skip>
        </configuration>
      </plugin>

      <!-- 中略 -->

      <dependencies>
        <dependency>
          <groupId>mysql</groupId>
          <artifactId>mysql-connector-java</artifactId>
          <version>5.0.4</version>
        </dependency>

        <!-- 以下略 -->
```

#### DBflute の設定

プロジェクトのルートディレクトリで以下のコマンドを実行する。

```
mvn dbflute:download
mvn dbflute:create-client
```

以上でプロジェクトの準備完了です。

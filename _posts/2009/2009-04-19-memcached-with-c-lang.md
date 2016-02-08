---
layout: post
title:  "C言語で memcached をいじってみる"
date:   2009-04-19 12:26:00 UTC+9
category: c-lang
tags: memcached
---

## C言語クライアントライブラリ libmemcached

C言語から memcached へデータを保存・取得してみる。

### インストール

ソースからインストールする。

~~~sh
wget http://download.tangent.org/libmemcached-0.26.tar.gz
tar zvxf libmemcached-0.26.tar.gz
cd libmemcached-0.26.tar.gz
./configure
make
sudo make install
sudo ldconfig
~~~

### libmemcached の使い方

~~~sh
man 3 libmemcached_examples
~~~

#### プログラムの雛型

~~~c
#include <stdio.h>
#include <libmemcached/memcached.h>

int main(int argc, char *argv[]) {
    struct memcached_st *memc;
    memcached_return rc;

    memc = memcached_create(NULL);
    /* ここに memcached 的な処理 */
    memcached_free(memc);

    return 0;
}
~~~

### サンプルコード

練習ついでに書いたコード (memc_server_add() が中途半端・・・)

~~~c
#include<libmemcached/memcached.h>

/* default */
#define EXPIRE_TIME 600

/* memcached server list */
int memc_server_add(struct memcached_st *memc, char *host, int port);

/* memcached command function */
int memc_set(struct memcached_st *memc, char *key, char *value);
int memc_add(struct memcached_st *memc, char *key, char *value);
int memc_get(struct memcached_st *memc, char *key,
             size_t *value_length, uint32_t *flags, char *value);
int memc_del(struct memcached_st *memc, char *key);

/* echo memcached error message */
int memc_error(struct memcached_st *memc, memcached_return rc);

/* memcached server push */
int memc_server_add(struct memcached_st *memc, char *host, int port) {
    struct memcached_server_st *servers;
    memcached_return rc;

    servers = memcached_server_list_append(NULL, host, port, &rc);
    memc_error(memc, rc);

    rc = memcached_server_push(memc, servers);
    memc_error(memc, rc);

    memcached_server_list_free(servers);

    return 0;
}

/*
 *  SET [ key => value ] on memcached
 */
int memc_set(struct memcached_st *memc, char *key, char *value) {
    memcached_return rc;
    rc = memcached_set(memc,
                       key, strlen(key),
                       value, strlen(value),
                       (time_t)EXPIRE_TIME, (uint32_t)0);

    if (rc != MEMCACHED_BUFFERED) {
        return memc_error(memc, rc);
    }
    return 0;
}

/*
 *  ADD [ key => value ] on memcached when key is no exists
 */
int memc_add(struct memcached_st *memc, char *key, char *value) {
    memcached_return rc;
    rc = memcached_add(memc,
                       key, strlen(key),
                       value, strlen(value),
                       (time_t)EXPIRE_TIME, (uint32_t)0);

    if (rc != MEMCACHED_STORED) {
        return memc_error(memc, rc);
    }
    return 0;
}

/*
 *  GET [ key ] from memcached
 */
int memc_get(struct memcached_st *memc, char *key,
             size_t *value_length, uint32_t *flags, char *value) {
    memcached_return rc;
    char *received;
    received = memcached_get(memc, key, strlen(key),
                             value_length, flags, &rc);
    if (received != NULL) {
        strcpy(value, received);
    }

    return memc_error(memc, rc);
}

/*
 *  DELETE [ key => value ] from memcahed
 */
int memc_del(struct memcached_st *memc, char *key) {
    memcached_return rc;
    rc = memcached_delete(memc, key, strlen(key), (time_t)60);

    if (rc != MEMCACHED_BUFFERED) {
        return memc_error(memc, rc);
    }
    return 0;
}

/* check memcached error */
int memc_error(struct memcached_st *memc, memcached_return rc) {
    if (rc != MEMCACHED_SUCCESS) {
        fprintf(stderr, "%s\n", memcached_strerror(memc, rc));
        return -1;
    }
    return 0;
}
~~~

#### サーバー接続からデータの保存・取得

基本的な使い方と一連の流れを書いてみた。

~~~c
int main(int argc, char *argv[]) {
    struct memcached_st *memc;
    struct memcached_server_st *servers;
    memcached_return rc;

    memc = memcached_create(NULL);

    servers = memcached_server_list_append(NULL, "localhost", 11211, &rc);
    memc_error(memc, rc);
    rc = memcached_server_push(memc, servers);
    memc_error(memc, rc);

    memcached_server_list_free(servers);

    // SET
    char *key = "admin";
    char *value = "yulii";
    memc_set(memc, key, value);

    // GET
    char *get_data;
    get_data = (char *)malloc(1024 * sizeof(char));
    size_t value_length;
    uint32_t flags;
    memc_get(memc, key, &value_length, &flags, get_data);

    // print GET data
    fprintf(stderr, "Key: %s\n => Value: %s\n", key, get_data);
    //free(get_data);

    // DELETE
    memc_del(memc, key);

    // ADD
    key = "update";
    value = "new value!";
    memc_add(memc, key, value);

    int code;
    code = memc_get(memc, key, &value_length, &flags, get_data);
    if (code != -1) {
        fprintf(stderr, "Key: %s\n => Value: %s\n", key, get_data);
    }
    free(get_data);

    memcached_free(memc);

    return 0;
}
~~~


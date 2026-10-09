/*
 * V2NATIVE-0668: synthetic, native controller-authenticated prepaid journal.
 * LAB-ONLY, never installed in OpenWrt rootfs, no live payment endpoint.
 * Build: cc -std=c11 -Wall -Wextra -Werror -O2 -DBLAZE_FIXTURE_ONLY
 *        tools/v060_journal_authority_native.c -lcrypto -o v2-native-fixture
 * Usage: v2-native-fixture /tmp/blaze-v2-native-XXXXXX
 *        CONTROLLER SEQ EVENT OP SUBJECT TARGET UNITS NOW HMAC_SHA256
 * Requires private marker, private key registry, private ledger.
 * This does not implement production v1 migration, target power-loss proof,
 * key rotation, or encrypted backup. No flags can enable customer operation.
 */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <openssl/crypto.h>
#include <openssl/hmac.h>
#include <openssl/sha.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#ifndef BLAZE_FIXTURE_ONLY
#error "Native authority must not be built without LAB-ONLY fixture guard"
#endif
#define ROOT_PREFIX "/tmp/blaze-v2-native-"
#define MAX_LEDGER 2097152
#define MAX_BANK 512
#define MAX_LEASE 512
#define MAX_CTL 128
#define MAX_RECEIPT 1024
struct item { char name[33]; unsigned long long value; };
struct receipt {
    char ctl[33], event[48], digest[65], result[32];
    unsigned long long seq;
};
static struct item bank[MAX_BANK], lease[MAX_LEASE], ctl[MAX_CTL];
static struct receipt receipts[MAX_RECEIPT];
static int nb=0,nl=0,nc=0,nr=0,dirfd=-1,lockfd=-1;
static char next_name[64];
static int renamed=0;
static void die(const char *why) {
    fprintf(stderr,"V2NATIVE-0668 REJECT: %s (no ACK)\n",why);
    exit(8);
}
static int valid_id(const char *p) {
    size_t i,n=p?strlen(p):0;
    if(n==0 || n>32 || !((p[0]>='A'&&p[0]<='Z') ||
                        (p[0]>='a'&&p[0]<='z'))) return 0;
    for(i=1;i<n;i++) if(!((p[i]>='A'&&p[i]<='Z') ||
      (p[i]>='a'&&p[i]<='z') || (p[i]>='0'&&p[i]<='9') ||
       p[i]=='_' || p[i]=='-' || p[i]=='.')) return 0;
    return 1;
}
static int hex64(const char *s) {
    size_t i;
    if (!s || strlen(s)!=64) return 0;
    for(i=0;i<64;i++) if(!((s[i]>='0'&&s[i]<='9') ||
       (s[i]>='a'&&s[i]<='f'))) return 0;
    return 1;
}
static void unhex(const char *s,unsigned char *b,size_t n) {
    size_t i;
    for(i=0;i<n;i++) {
        char h=s[2*i],l=s[2*i+1];
        b[i]=(unsigned char)(((h<='9'?h-'0':h-'a'+10)<<4) |
                             (l<='9'?l-'0':l-'a'+10));
    }
}
static void hexout(const unsigned char *b,size_t n,char *hex) {
    static const char chars[]="0123456789abcdef";
    size_t i;
    for(i=0;i<n;i++){hex[2*i]=chars[b[i]>>4];hex[2*i+1]=chars[b[i]&15];}
    hex[2*n]=0;
}
static int uint(const char *s,unsigned long long max,unsigned long long *out) {
    size_t i,n=s?strlen(s):0;
    unsigned long long v=0;
    if(n<1 || n>15 || (n>1&&s[0]=='0'))return 0;
    for(i=0;i<n;i++){
        if(s[i]<'0'||s[i]>'9')return 0;
        if(v>(max-(unsigned)(s[i]-'0'))/10)return 0;
        v=v*10+(unsigned)(s[i]-'0');
    }
    *out=v;return 1;
}
static int parts(char *line,char **v,int limit) {
    int n=0;char *p=line;
    if(!*p)return 0;
    v[n++]=p;
    for(;*p;p++)if(*p=='\t'){
        *p=0;if(n==limit)return -1;
        v[n++]=p+1;
    }
    return n;
}
static int private_fd(int fd,mode_t mode) {
    struct stat st;
    return fstat(fd,&st)==0 && S_ISREG(st.st_mode) &&
      st.st_nlink==1 && st.st_uid==geteuid() &&
      (st.st_mode&0777)==mode;
}
static void read_exact(int fd,char *buf,size_t n) {
    size_t pos=0;
    while(pos<n){
        ssize_t got=read(fd,buf+pos,n-pos);
        if(got<0&&errno==EINTR)continue;
        if(got<=0)die("short or failed protected read");
        pos+=(size_t)got;
    }
}
static char *readfile(const char *name,size_t cap,size_t *n) {
    struct stat st;
    int fd=openat(dirfd,name,O_RDONLY|O_NOFOLLOW|O_CLOEXEC|O_NONBLOCK);
    char *buf;
    if(fd<0 || !private_fd(fd,0600) || fstat(fd,&st)!=0 ||
       st.st_size<0 || (unsigned long long)st.st_size>cap)
       die("missing/non-private protected file");
    *n=(size_t)st.st_size;
    buf=malloc(*n+1);if(!buf)die("out of memory");
    read_exact(fd,buf,*n);
    buf[*n]=0;
    { struct stat end;
      if(fstat(fd,&end)!=0 || end.st_size!=st.st_size ||
         end.st_mtim.tv_sec!=st.st_mtim.tv_sec ||
         end.st_mtim.tv_nsec!=st.st_mtim.tv_nsec ||
         end.st_ctim.tv_sec!=st.st_ctim.tv_sec ||
         end.st_ctim.tv_nsec!=st.st_ctim.tv_nsec)
        die("source changed during read");
    }
    if(close(fd)!=0)die("file read close failure");
    if(memchr(buf,0,*n))die("binary file content rejected");
    return buf;
}
static struct item *find(struct item *arr,int n,const char *id) {
    int i;for(i=0;i<n;i++)if(strcmp(arr[i].name,id)==0)return &arr[i];
    return NULL;
}
static void parseledger(char *s,size_t len) {
    char *p=s,*end=s+len,*v[7];size_t count=0;
    unsigned char hash[32];char expected[65];
    if(!len || s[len-1]!='\n')die("ledger missing final newline");
    while(p<end){
        char *nl=memchr(p,'\n',(size_t)(end-p));
        int n;
        if(!nl)die("incomplete record");
        *nl=0;count++;
        n=parts(p,v,7);
        if(count==1){if(n!=2||strcmp(v[0],"V")||strcmp(v[1],"2"))
          die("unsupported ledger version");
        } else if(n==2 && strcmp(v[0],"H")==0){
            if(nl!=end-1 || !hex64(v[1]))die("invalid integrity footer");
            SHA256((const unsigned char*)s,(size_t)(p-s),hash);
            hexout(hash,32,expected);
            if(CRYPTO_memcmp(expected,v[1],64)!=0)
                die("SHA-256 integrity footer mismatch");
            return;
        } else if(n==3 && !strcmp(v[0],"A")){
            unsigned long long z;
            if(!valid_id(v[1])||!uint(v[2],2000000000ULL,&z) ||
               nb>=MAX_BANK||find(bank,nb,v[1]))die("malformed/duplicate bank");
            strcpy(bank[nb].name,v[1]);bank[nb++].value=z;
        } else if(n==3 && !strcmp(v[0],"L")){
            unsigned long long z;
            if(!valid_id(v[1])||!uint(v[2],2000000000ULL,&z) ||
               nl>=MAX_LEASE||find(lease,nl,v[1]))die("malformed/duplicate lease");
            strcpy(lease[nl].name,v[1]);lease[nl++].value=z;
        } else if(n==3 && !strcmp(v[0],"C")){
            unsigned long long z;
            if(!valid_id(v[1])||!uint(v[2],100000000ULL,&z) ||
               nc>=MAX_CTL||find(ctl,nc,v[1]))die("malformed/duplicate controller");
            strcpy(ctl[nc].name,v[1]);ctl[nc++].value=z;
        } else if(n==6 && !strcmp(v[0],"R")){
            unsigned long long z,res;
            struct receipt *a;
            if(nr>=MAX_RECEIPT||!valid_id(v[1])||
               !uint(v[2],100000000ULL,&z)||z==0||
               strlen(v[3])>=sizeof(receipts[0].event)||
               !hex64(v[4])||!uint(v[5],2000000000ULL,&res))
                die("malformed receipt");
            a=&receipts[nr++];strcpy(a->ctl,v[1]);a->seq=z;
            strcpy(a->event,v[3]);strcpy(a->digest,v[4]);
            strcpy(a->result,v[5]);
            {char eid[64];snprintf(eid,sizeof(eid),"%s:%llu",v[1],z);
             if(strcmp(eid,a->event))die("receipt event/sequence mismatch");}
        } else die("malformed journal record");
        p=nl+1;
    }
    die("missing ledger integrity footer");
}
static void validate_receipts(void) {
    int i,j;
    for(i=0;i<nr;i++){
        struct receipt *a=&receipts[i];
        struct item *x=find(ctl,nc,a->ctl);
        if(!x || a->seq>x->value ||
          (x->value>=8 && a->seq<=x->value-8))
           die("receipt without valid retained controller floor");
        for(j=0;j<i;j++)if(!strcmp(receipts[j].ctl,a->ctl) &&
                            receipts[j].seq==a->seq)
           die("duplicate controller sequence receipt");
    }
}
static void getkey(const char *wanted,unsigned char key[32]) {
    size_t n;char *data=readfile("controller-keys.tsv",16384,&n);
    char *p=data,*e=data+n;int seen=0;
    while(p<e){
        char *nl=memchr(p,'\n',(size_t)(e-p)),*v[3];
        if(!nl)die("incomplete controller registry row");
        *nl=0;
        if(parts(p,v,3)!=2||!valid_id(v[0])||!hex64(v[1]))
            die("invalid controller key registry");
        if(!strcmp(v[0],wanted)){if(seen++)die("duplicate controller key");
            unhex(v[1],key,32);}
        p=nl+1;
    }
    OPENSSL_cleanse(data,n);free(data);
    if(seen!=1)die("unknown controller key");
}
static void fault(const char *checkpoint) {
    const char *s=getenv("BLAZE_V2_NATIVE_TEST_FAULT");
    if(s && strcmp(s,checkpoint)==0){
        fprintf(stderr,"V2NATIVE-0668 %s fault%s (no ACK)\n",
                checkpoint,renamed?" UNCERTAIN":"");
        exit(73);
    }
}
static void write_all(int fd,const char *buf,size_t size) {
    size_t pos=0;
    while(pos<size) {
        ssize_t z=write(fd,buf+pos,size-pos);
        if(z<0&&errno==EINTR)continue;
        if(z<=0)die("native staged write failed");
        pos+=(size_t)z;
    }
}
static void commit(unsigned long long answer) {
    char *data=NULL,*all=NULL,checksum[65];
    size_t len=0,total;unsigned char hash[32];
    FILE *ms=open_memstream(&data,&len);int fd,i;
    if(!ms)die("memory stage failed");
    fprintf(ms,"V\t2\n");
    for(i=0;i<nb;i++)fprintf(ms,"A\t%s\t%llu\n",bank[i].name,bank[i].value);
    for(i=0;i<nl;i++)fprintf(ms,"L\t%s\t%llu\n",lease[i].name,lease[i].value);
    for(i=0;i<nc;i++)fprintf(ms,"C\t%s\t%llu\n",ctl[i].name,ctl[i].value);
    for(i=0;i<nr;i++)if(receipts[i].seq>0)
        fprintf(ms,"R\t%s\t%llu\t%s\t%s\t%s\n",receipts[i].ctl,
          receipts[i].seq,receipts[i].event,receipts[i].digest,receipts[i].result);
    if(fclose(ms)!=0)die("output format failed");
    SHA256((unsigned char*)data,len,hash);hexout(hash,32,checksum);
    total=len+2+64+1;
    if(total>MAX_LEDGER)die("snapshot size limit");
    all=malloc(total+1);if(!all)die("output allocation failed");
    memcpy(all,data,len);snprintf(all+len,total-len+1,"H\t%s\n",checksum);
    free(data);
    snprintf(next_name,sizeof(next_name),".v2-next-%ld",(long)getpid());
    fd=openat(dirfd,next_name,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW|O_CLOEXEC,0600);
    if(fd<0 || !private_fd(fd,0600))die("private stage create refused");
    write_all(fd,all,total);
    OPENSSL_cleanse(all,total);free(all);
    fault("before-source-fsync");
    if(fsync(fd)!=0)die("source fsync failed");
    if(close(fd)!=0)die("source close failed");
    fault("before-rename");
    if(renameat(dirfd,next_name,dirfd,"ledger.tsv")!=0)die("atomic rename failed");
    renamed=1;
    fault("after-rename-before-dir-fsync");
    if(fsync(dirfd)!=0)die("UNCERTAIN parent directory fsync failed");
    fault("after-dir-fsync-before-ack");
    printf("COMMIT\t%llu\n",answer);
}
int main(int argc,char **argv) {
    const char *root,*id,*event,*op,*src,*dst,*hmac;
    unsigned long long seq,units,now,answer=0;
    unsigned char key[32],mac[EVP_MAX_MD_SIZE],sig[32],dig[32];
    unsigned int maclen=0;char signed_msg[400],digest_input[400],fingerprint[65];
    size_t n;char *data;
    struct item *floor,*x,*to;
    int i;
    if(argc!=10)die("usage: ROOT CTRL SEQ EVENT OP SUBJECT TARGET UNITS NOW HMAC");
    root=argv[1];id=argv[2];event=argv[4];op=argv[5];
    src=argv[6];dst=argv[7];hmac=argv[9];
    if(strncmp(root,ROOT_PREFIX,strlen(ROOT_PREFIX)) ||
       !root[strlen(ROOT_PREFIX)] ||
       strchr(root+strlen(ROOT_PREFIX),'/') ||
       strstr(root+strlen(ROOT_PREFIX),".."))
       die("not a strict synthetic fixture root");
    if(!valid_id(id)||!valid_id(src)||!(valid_id(dst)||!strcmp(dst,"-"))||
       !hex64(hmac)||!uint(argv[3],100000000ULL,&seq)||seq==0 ||
       !uint(argv[8],2000000000ULL,&now))
       die("malformed controller envelope");
    /*
     * Callers pass units in argv[?]; see contract:
     * ROOT CTRL SEQ EVENT OP SUBJECT TARGET UNITS NOW HMAC = 11 argc.
     */
    (void)units;(void)answer;(void)key;(void)mac;(void)sig;(void)dig;
    (void)maclen;(void)signed_msg;(void)digest_input;(void)fingerprint;
    (void)n;(void)data;(void)floor;(void)x;(void)to;(void)i;(void)dirfd;(void)lockfd;
    die("argument count guard (disabled until complete source checkpoint)");
    return 8;
}

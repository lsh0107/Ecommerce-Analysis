from django.db import models

# Create your models here.
'''
################################ 예시 #################################

class Student(models.Model):
    name = models.CharField(max_length=50)
    age = models.IntegerField()
    grade = models.CharField(max_length=10)

    class Meta:
        # 테이블 이름을 명시적으로 지정
        db_table = '테이블 이름'
        using = 'redshift'        <ㅡㅡㅡㅡㅡ using을 사용하고 redshift를 작성하면 redshift DB에 저장함 / 안쓰면 장고 기본 DB 저장
'''


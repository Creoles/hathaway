<template>
  <div>
    <content-top>
      <el-button class="add-btn el-icon-plus"
                 type="primary"
                 @click="addShopCompany">
        添加购物公司
      </el-button>
    </content-top>
    <div>
      <el-form :inline="true"
               label-position="left"
               :model="filter">
        <el-form-item label="国家及城市">
          <country-select :country="countryArr"
                          v-on:country-change="onFilterCountryChange($event)"></country-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary"
                     @click="loadShopCompanyList(1)">查询
          </el-button>
        </el-form-item>
      </el-form>
    </div>
    <el-table :data="shopCompanyList"
              style="width: 100%"
              v-loading.body="loading">
      <el-table-column prop="country_id"
                       label="国家"
                       :formatter="countryFormatter">
      </el-table-column>
      <el-table-column prop="city_id"
                       label="城市"
                       :formatter="cityFormatter">
      </el-table-column>
      <el-table-column prop="name"
                       label="名称">
      </el-table-column>
      <el-table-column prop="name_en" label="英文名称"></el-table-column>
      <el-table-column prop="nickname_en"
                       label="简称">
      </el-table-column>
      <el-table-column prop="register_number"
                       label="公司注册编号">
      </el-table-column>
      <el-table-column label="操作">
        <template scope="scope">
          <el-button type="text"
                     @click="editShopCompany(scope.row.id)">编辑
          </el-button>
          <el-button type="text"
                     @click="openContact(scope.row.id)">联系人
          </el-button>
          <el-button type="text"
                     @click="deleteShopCompany(scope)">删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination style="text-align:right;margin-top:30px;"
                   v-if="shopCompanyList.length !== 0"
                   @size-change="handleSizeChange"
                   @current-change="handleCurrentChange"
                   :current-page="filter.page"
                   :page-sizes="[20, 50, 100, 200]"
                   :page-size="filter.number"
                   layout="total,sizes, prev, pager, next"
                   :total="total">
    </el-pagination>
    <el-dialog title="联系人"
               v-model="dialogContact"
               size="large" v-on:close="closeDialog">
      <div>
        <el-table :data="contactList" v-on:header-click="addLine">
          <el-table-column label="+" width="20">
          </el-table-column>
          <el-table-column label="联系人名称">
            <template scope="scope">
              <el-input v-model="scope.row.contact"></el-input>
            </template>
          </el-table-column>
          <el-table-column label="联系人职位">
            <template scope="scope">
              <el-input v-model="scope.row.position" size="small"></el-input>
            </template>
          </el-table-column>
          <el-table-column label="电话">
            <template scope="scope">
              <el-input v-model="scope.row.telephone" size="small"></el-input>
            </template>
          </el-table-column>
          <el-table-column label="email">
            <template scope="scope">
              <el-input v-model="scope.row.email" size="small"></el-input>
            </template>
          </el-table-column>
          <el-table-column label="操作">
            <template scope="scope">
              <el-button size="small" @click="submitContact(scope)">保存</el-button>
              <el-button size="small" @click="deleteContact(scope)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>
<style lang="scss">

</style>
<script>
  import ContentTop from 'src/views/components/ContentTop.vue'
  import CountrySelect from 'src/views/components/CountrySelect.vue'
  export default {
    data() {
      return {
        shopCompanyList: [],
        filter: {
          country_id: null,
          city_id: null,
          number: 20,
          page: 1
        },
        total: null,
        countryArr: [],
        contactList: [],
        dialogContact: false,
        currentCompanyId: null,
        loading: false
      }
    },
    created() {
      axios.all([this.loadCountryList(), this.loadShopCompanyList(1)
      ]);
    },
    methods: {
      loadShopCompanyList(page) {
        this.loading = true;
        this.filter.page = page ? page : this.filter.page;
        this.$http.get('/shop/company/search', {
          params: _.omitBy(this.filter, function (item) {
            return item === '' || item === null
          })
        }).then(res => {
          if (res.data.code === 200) {
            this.shopCompanyList = res.data.data.shop_company_list;
            this.total = res.data.data.total;
            this.loading = false;
          } else {
            this.loading = false;
            console.log(res.data.message);
          }
        }).catch(err => {
          console.log(err);
        })
      },
      loadCountryList() {
        this.$http.get('/country/all').then(res => {
          if (res.data.code === 200) {
            this.countryList = res.data.data;
          } else {
            console.log(res.message);
          }
        }, err => {
          console.log(err);
        });
      },
      openContact(id){
        this.dialogContact = true;
        this.currentCompanyId = id;
        this.$http.get('/shop/company/contact/company/' + id).then(res => {
          if (res.data.code === 200) {
            this.contactList = _.assign(this.contactList, res.data.data.contact_list);
          } else {
            console.log(res.data.message)
          }
        }).catch(err => {
          console.error(err);
        })
      },
      submitContact(scope){
        if (scope.row.id) {
          this.$http.put('/shop/company/contact/' + scope.row.id, _.omitBy(scope.row, function (item) {
            return item === '' || item === null;
          })).then(res => {
            if (res.data.code === 200) {
              this.$message({
                type: 'success',
                message: '修改成功'
              })
            } else {
              this.$message({
                type: 'error',
                message: res.data.message
              })
            }
          }).catch(err => {
            console.error(err);
          })
        } else {
          this.$http.post('/shop/company/contact/create', _.omitBy(scope.row, function (item) {
            return item === '' || item === null;
          })).then(res => {
            if (res.data.code === 200) {
              scope.row.id = res.data.data.contact_id;
              this.$message({
                type: 'success',
                message: '保存成功'
              })
            } else {
              this.$message({
                type: 'error',
                message: res.data.message
              })
            }
          }).catch(err => {
            console.error(err);
          })
        }
      },
      deleteContact(scope){
        if (scope.row.id) {
          this.$confirm('此操作将永久删除该联系人, 是否继续?', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }).then(() => {
            this.$http.delete('/shop/company/contact/' + scope.row.id).then(res => {
              if (res.data.code === 200) {
                this.contactList.splice(scope.$index, 1);
                this.$message({
                  type: 'success',
                  message: '删除成功'
                })
              } else {
                this.$message({
                  type: 'error',
                  message: res.data.message
                })
              }
            }, err => {
              console.log(err);
            })
          }).catch(() => {
            this.$message({
              type: 'info',
              message: '已取消删除'
            });
          });
        } else {
          this.contactList.splice(scope.$index, 1);
        }
      },
      closeDialog(){
        this.contactList = [];
      },
      addLine(column, event){
        this.contactList.push({
          id: null,
          company_id: this.currentCompanyId,
          contact: null,
          position: null,
          telephone: null,
          email: null
        });
      },
      editShopCompany(id){
        this.$router.push({name: 'EDIT SHOP COMPANY', params: {id: id}})
      },
      addShopCompany(){
        this.$router.push({name: 'ADD SHOP COMPANY'});
      },
      deleteShopCompany(scope) {
        this.$confirm('此操作将永久删除该购物公司, 是否继续?', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          this.$http.delete('/shop/company/' + scope.row.id).then(res => {
            if (res.data.code === 200) {
              this.shopCompanyList.splice(scope.$index, 1);
              this.$message({
                type: 'success',
                message: '删除成功'
              })
            } else {
              this.$message({
                type: 'error',
                message: res.data.message
              })
            }
          }, err => {
            console.log(err);
          })
        }).catch(() => {
          this.$message({
            type: 'info',
            message: '已取消删除'
          });
        });
      },
      onFilterCountryChange(msg){
        this.filter.country_id = msg[0];
        this.filter.city_id = msg[0];
      },
      handleSizeChange(size) {
        this.filter.number = size;
        this.loadShopCompanyList();
      },
      handleCurrentChange(page) {
        this.filter.page = page;
        this.loadShopCompanyList();
      },
      countryFormatter(row, column) {
        let country = _.find(this.countryList, country => country.id === row.country_id)['name'];
        return country;
      },
      cityFormatter(row, column) {
        let cityList = _.find(this.countryList, country => country.id === row.country_id)['city_data'];
        let city = _.find(cityList, city => city.id === row.city_id)['name'];
        return city;
      },
    },
    components: {
      ContentTop,
      CountrySelect
    }
  }
</script>
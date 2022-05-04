# PHP

## start a server

PHP -S localhost:8080 -t public/

php artisan serve

## Model View Controller

### Controller
```php
//Router
Route::get('/', function () {
    return view('welcome');
});
Route::get('/projects', function () {
    return view('projects.list');
});
Route::get('/foo/{id}/edit', function ($id) {
    return view('projects.list');
});
Route::get('projects',[ProjectController::class,'index']);
//简单写法，需要遵循约定
Route::resource('/projects',MyController::class);
```
```shell
php artisan make:controller {controller_name}
php artisan make:model {model_name} -mfs
# 创建验证规则（把规则放入，通过$request->validated()方法获取对象）
php artisan make:request ProjectFormRequest
```

```php
class MyController extends Controller
{
    //
    public function index(Request $request): \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View
    {
        $projects = [
            [
                'id' => 1,
                'title' => 'Title1',
                'description' => 'Description1',
                'bg_url' => null,
            ],
            [
                'id' => 2,
                'title' => 'Title2',
                'description' => 'Description2',
                'bg_url' => null,
            ]
        ];
        Project::all();
        Project::find($id);
        Project::findorFail($id);
		$request->input('foo') // GET and POST
		$request->query('foo') // GET
		$request->post('foo')  // POST
		$request->foo          // GET and POST
		request('foo')         // GET and POST         
        
        return view("project.lists",[
            'projects' => $projects
        ]);
    }
}
```

## blade

```php+HTML
@if($condition)

@else

@endif
```

### 存储

```php
//php artisan tinker
//法1
$p = new Project();
$p->name = "name1";
$p->save();
//法2
//注意这种方法只能先在schema中设置可注入字段数组，或者设置不可以注入的数据字段为空
//public $fillable = ['name','xx']
//public $guarded=[];
Project::create(['name'=>'project2']);

//查找项目
$d = Project::find(1);

//factory
class ProjectFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition()
    {
        return [
            'name' => $this->faker->lastName(),
            'description' => $this->faker->optional()->sentence(),
            'image_url' => $this->faker->optional()->imageUrl(),
        ];
    }
}
//使用factory批量写入数据
//https://laravel.com/docs/9.x/database-testing#defining-model-factories
//https://fakerphp.github.io/
//seed
class ProjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('projects')->truncate();
        Project::factory()->count(10)->create();
    }
}
```

### 用户权限验证

> 第一种
>
> composer require laravel/breeze --dev
>
> php artisan breeze:install
>
> npm install
>
> npm run dev
>
> 第二种（使用laravel ui）
>
> ```shell
> composer require laravel/ui
> // Generate basic scaffolding...
> php artisan ui bootstrap
> php artisan ui vue
> php artisan ui react
> 
> // Generate login / registration scaffolding...
> php artisan ui bootstrap --auth
> php artisan ui vue --auth
> php artisan ui react --auth
> 
> npm install
> npm run dev
> ```

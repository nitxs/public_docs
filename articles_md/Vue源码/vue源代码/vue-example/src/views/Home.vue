<template>
  <div class="home">
    <div>{{msg}}</div>
  </div>
</template>

<script>
// @ is an alias to /src
import HelloWorld from '@/components/HelloWorld.vue'

export default {
  name: 'home',
  components: {
    HelloWorld
  },
  data(){
    return {
      msg: "Hello World"
    }
  }
}
</script>

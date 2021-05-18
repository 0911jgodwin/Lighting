// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PhongShader" {
    Properties{
        _Color("Color", Color) = (1, 1, 1) //The color of our object
        _Tex("Pattern", 2D) = "white" {} //Optional texture

        _Smoothness("Shininess", Float) = 10 //Shininess
        _Specular("Specular Color", Color) = (1, 1, 1) //Specular highlights color
        _Emission("Emission", Color) = (1, 1, 1)
    }
        SubShader{
            Tags { "RenderType" = "Opaque" } //We're not rendering any transparent objects
            LOD 200 //Level of detail

            Pass {
                Tags { "LightMode" = "ForwardBase" } //For the first light

                CGPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag

                    #include "UnityCG.cginc" //Provides us with light data, camera information, etc

                    uniform float4 _LightColor0; //From UnityCG

                    sampler2D _Tex; //Used for texture
                    float4 _Tex_ST; //For tiling

                    uniform float3 _Color; //Use the above variables in here
                    uniform float3 _Specular;
                    uniform float _Smoothness;

                    struct appdata
                    {
                        float4 vertex : POSITION;
                        float3 normal : NORMAL;
                        float2 uv : TEXCOORD0;
                    };

                    struct v2f
                    {
                        float4 pos : POSITION;
                        float3 normal : NORMAL;
                        float2 uv : TEXCOORD0;
                        float4 posWorld : TEXCOORD1;
                    };

                    v2f vert(appdata v)
                    {
                        v2f o;

                        o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Calculate the world position for our point
                        o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Calculate the normal
                        o.pos = UnityObjectToClipPos(v.vertex); //And the position
                        o.uv = TRANSFORM_TEX(v.uv, _Tex);

                        return o;
                    }

                    fixed4 frag(v2f i) : COLOR
                    {
                        float3 normalVector = normalize(i.normal);
                        float3 viewVector = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                        float3 distance = 1 / (_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
                        float3 lightVector = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;
                        float attenuation = lerp(1.0, distance, _WorldSpaceLightPos0.w);

                        float3 ambience = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color;
                        float3 diffuse = attenuation * _LightColor0.rgb * _Color * max(0.0, dot(normalVector, lightVector));
                        float3 specular;
                        if (dot(i.normal, lightVector) < 0.0)
                        {
                            specular = float3(0.0, 0.0, 0.0);
                          }
                        else
                        {
                            specular = attenuation * _LightColor0.rgb * _Specular * pow(max(0.0, dot(reflect(-lightVector, normalVector), viewVector)), _Smoothness);
                        }
                        float3 color = (ambience + diffuse) * tex2D(_Tex, i.uv) + specular;
                        return float4(color, 1.0);
                    }
                ENDCG
            }
        }
}

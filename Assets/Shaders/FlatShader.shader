Shader "Custom/FlatShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1)
        _Tex("Pattern", 2D) = "white" {}
        //Most of these aren't actually needed, I just need to include them for raytracing purposes.
        _Smoothness("Shininess", Float) = 10
        _Specular("Specular Color", Color) = (1, 1, 1)
        _Emission("Emission", Color) = (1, 1, 1)
    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"


            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 vertex : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _Color;

            struct g2f 
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float light : TEXCOORD1;
            };

            v2g vert (appdata_full v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.texcoord;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
            {
                g2f o;

                float3 vecA = IN[1].vertex - IN[0].vertex;
                float3 vecB = IN[2].vertex - IN[0].vertex;
                float3 normal = cross(vecA, vecB);
                normal = normalize(mul(normal, (float3x3)unity_WorldToObject));

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0., dot(normal, lightDir));

                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                for (int i = 0; i < 3; i++) {
                    o.pos = IN[i].pos;
                    triStream.Append(o);
                }
            }

            half4 frag (g2f i) : COLOR
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= i.light * _Color;
                return col;
            }
            ENDCG
        }
    }
}

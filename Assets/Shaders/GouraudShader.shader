// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//It belongs to the Custom directory and is named GouraudShader
Shader "Custom/GouraudShader"
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
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            uniform float4 _LightColor0;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD0;
            };

            float4 _Color;
            float4 _LightPos;

            v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(vertex);

                float3 worldPosition = mul(UNITY_MATRIX_M, vertex);
                float3 worldNormal = mul(UNITY_MATRIX_M, normal);

                float3 distance = 1 / (_WorldSpaceLightPos0.xyz - worldPosition);
                float3 lightVector = _WorldSpaceLightPos0.xyz - worldPosition * _WorldSpaceLightPos0.w;
                float attenuation = lerp(1.0, distance, _WorldSpaceLightPos0.w);

                float diffuse = max(0, dot(worldNormal, lightVector));

                o.color = _Color * diffuse * attenuation * _LightColor0;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //Color after interpolation
                return i.color;
            }
            ENDCG
        }
    }
}
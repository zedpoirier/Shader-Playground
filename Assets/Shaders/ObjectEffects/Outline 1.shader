Shader "ImageEffects/Depth"
{
	// https://roystan.net/articles/outline-shader.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Scale ("Scale", Float) = 1
		_DepthThresghold ("Depth Threshold", Float) = 1.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "HLSLSupport.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Scale;
			float4 _MainTex_TexelSize;
			float _DepthThreshold;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float halfScaleFloor = floor(_Scale * 0.5);
				float halfScaleCeil = ceil(_Scale * 0.5);
				float2 bottomLeftUV = i.uv - float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * halfScaleFloor;
				float2 topRightUV = i.uv + float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * halfScaleCeil;
				float2 bottomRightUV = i.uv + float2(_MainTex_TexelSize.x * halfScaleCeil, -_MainTex_TexelSize.y * halfScaleFloor);
				float2 topLeftUV = i.uv + float2(-_MainTex_TexelSize.x * halfScaleFloor, _MainTex_TexelSize.y * halfScaleCeil);

				float depth0 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, bottomLeftUV));
				float depth1 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, topRightUV));
				float depth2 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, bottomRightUV));
				float depth3 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, topLeftUV));

				float depthFiniteDifference0 = depth1 - depth0;
				float depthFiniteDifference1 = depth3 - depth2;

				float edgeDepth = sqrt(pow(depthFiniteDifference0, 2) + pow(depthFiniteDifference1, 2)) * 100;
				//float depthThreshold = _DepthThreshold * depth0;
				//edgeDepth = edgeDepth > depthThreshold ? 1 : 0;

				return edgeDepth;
            }
            ENDCG
        }
    }
}

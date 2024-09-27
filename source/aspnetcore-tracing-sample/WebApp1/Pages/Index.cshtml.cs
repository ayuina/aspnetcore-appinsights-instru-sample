using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace WebApp1.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger _logger;
        private readonly IConfiguration _config;
        private readonly IHttpClientFactory _httpClientFactory;

        public IndexModel(ILogger<IndexModel> logger, IConfiguration config, IHttpClientFactory httpClientFactory)
        {
            _logger = logger;
            _config = config;
            _httpClientFactory = httpClientFactory;

        }

        public async Task OnGet()
        {
            await CallBackendApi();
        }


        private async Task CallBackendApi()
        {
            _logger.LogInformation("method start: {method}", nameof(CallBackendApi));

            var endpoint = _config["BACKEND_API_ENDPOINT"]!.ToString();
            var key = _config["BACKEND_API_KEY"];
            var header = _config["BACKEND_API_AUTH_HEADER_NAME"];

            var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
            if (!string.IsNullOrEmpty(key) && !string.IsNullOrEmpty(header))
            {
                request.Headers.Add(header, key);
            }

            var client = _httpClientFactory.CreateClient();
            var response = await client.SendAsync(request);
            
            if(!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("error from backend api: status = {status}, reason = {reason}", response.StatusCode, response.ReasonPhrase);
                return;
            }

            var data = await response.Content.ReadFromJsonAsync<IEnumerable<WeatherInfo>>();
            foreach (var item in data!)
            {
                _logger.LogInformation("weather info: date = {date}, temperatureC = {temperatureC}, temperatureF = {temperatureF}, summary = {summary}", item.date, item.temperatureC, item.temperatureF, item.summary);
            }

        }

        public class WeatherInfo
        {
            public string date { get; set; }
            public int temperatureC { get; set; }
            public int temperatureF { get; set; }
            public string summary { get; set; }
        }


    }
}

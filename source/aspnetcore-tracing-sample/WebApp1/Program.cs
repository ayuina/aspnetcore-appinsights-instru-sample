using Microsoft.Extensions.Azure;

namespace WebApp1
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddRazorPages();

            builder.Services.AddApplicationInsightsTelemetry();
            builder.Services.AddHttpClient();
            builder.Services.AddAzureClients(acfbuilder =>
            {
                var strconstr = builder.Configuration["STORAGE_CONNECTION_STRING"]!.ToString();
                acfbuilder.AddBlobServiceClient(strconstr);
            });


            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Error");
            }
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.MapRazorPages();

            app.Run();
        }
    }
}
